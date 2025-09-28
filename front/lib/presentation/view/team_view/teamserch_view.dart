// ignore_for_file: use_build_context_synchronously, unused_result, library_private_types_in_public_api

import 'package:fineplay/presentation/viewmodel/search_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/teamsearch_provider.dart';

final deleteAllProvider = StateProvider<bool>((ref) => false);

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Teamsearch_view 클래스 바깥(또는 맨 위)에 추가
Future<void> _goToTeamDetail(
    String teamName,
    BuildContext context,
    WidgetRef ref,
    ) async {
  // 1) 로딩 인디케이터 띄우기
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // 2) Riverpod provider 를 통해 검색 API 호출 (FutureProvider)
    final teams = await ref.read(teamSearchProvider(teamName).future);

    // 3) 로딩 닫기
    Navigator.of(context).pop();

    if (teams.isEmpty) {
      // 검색 결과 없을 때 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$teamName" 결과가 없습니다.')),
      );
      return;
    }

    // 4) teamName 과 정확히 매칭되는 항목 찾기 (없으면 첫 번째)
    final team = teams.firstWhere(
          (t) => t.teamName == teamName,
      orElse: () => teams.first,
    );

    // 5) 상세 화면으로 바로 이동
    context.pushNamed(
      'searchedteam',

      pathParameters: {'teamId': team.teamId.toString()},
    );
  } catch (e) {
    // 에러 났을 때
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('검색 중 에러가 발생했습니다: $e')),
    );
  }
}

class Teamsearch_view extends ConsumerWidget {
  const Teamsearch_view({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    final query = ref.watch(searchQueryProvider);


    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(top:15.0*S.Y_RATIO),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: const Color(0xFF030319),
        actions: const [findingWidget()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (query.isNotEmpty) ...[
              Padding(
                padding:  EdgeInsets.only( top: S.Y_RATIO * 28,
                 ),
                child: Center(
                  child: Consumer(builder: (c, ref, _) {
                    ref.refresh(teamSearchProvider(query));
                    final results = ref.watch(teamSearchProvider(query));
                    return results.when(
                      data: (teams) => Column(
                        children: teams.map((t) => SearchResultBox(
                          teamName: t.teamName,
                          teamId: t.teamId,
                          onTap: () {
                            // ✅ 실제 클릭 시에만 기록 저장
                            ref.read(teamHistoryProvider.notifier).add(t.teamName);

                            context.pushNamed(
                              'searchedteam',

                              pathParameters: {'teamId': t.teamId.toString()},
                            );
                          },
                        )).toList(),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                        child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  }),
                ),
              ),
            ] else ...[
              // query 빈 값일 때만 recent UI 표시
              Padding(
                padding: EdgeInsets.only(
                  top: S.Y_RATIO * 28,
                  left: S.X_RATIO * 30,
                  right: S.X_RATIO * 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("최근검색",
                        style: TextStyle(
                            fontFamily: 'Wanted sans',
                            fontSize: 12 * S.Y_RATIO,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                    GestureDetector(
                      onTap: () {
                        ref.read(teamHistoryProvider.notifier).clear();
                      },
                      child: Text("전체 삭제",
                          style: TextStyle(
                              fontFamily: 'Wanted sans',
                              fontSize: 12 * S.Y_RATIO,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 11 * S.Y_RATIO),


              // 저장된 검색 기록 불러오기
              Consumer(builder: (context, ref, _) {
                final history = ref.watch(teamHistoryProvider);
                if (history.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 270 * S.Y_RATIO),
                    child: Text("최근 검색 기록이 없어요!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18 * S.Y_RATIO,
                          fontFamily: 'Wanted sans',
                          fontWeight: FontWeight.w400,
                        )),
                  );
                }
                return Column(
                  children: history.map((q) {
                     return RecentBox1(
                       query: q,
                       onTap: () {
                         _goToTeamDetail(q, context, ref);
                       },

                      onDelete: () {
                        // 개별 기록 삭제
                        ref.read(teamHistoryProvider.notifier).remove(q);
                      },
                    );
                  }).toList(),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}


// Teamsearch_view.dart 내 수정된 findingWidget

class findingWidget extends ConsumerStatefulWidget {
  const findingWidget({super.key});

  @override
  _FindingWidgetState createState() => _FindingWidgetState();
}

class _FindingWidgetState extends ConsumerState<findingWidget> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch() {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    // ✅ 기록 저장은 제거 (이제 여기선 하지 않음)
    // ref.read(teamHistoryProvider.notifier).add(q);

    // 🔁 검색 Query만 업데이트
    ref.read(searchQueryProvider.notifier).state = q;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: S.Y_RATIO * 15,
            right: S.X_RATIO * 28,
          ),
          child: Center(
            child: Container(
              height: 40,
              width: S.X_RATIO * 280,
              decoration: BoxDecoration(
                color: const Color(0xFF21213d),
                borderRadius: BorderRadius.circular(10.0 * S.Y_RATIO),
              ),
              child: Stack(
                children: [
                  // 입력 필드
                  Positioned.fill(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: '찾고 있는 팀이 있으신가요?',
                        hintStyle: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Wanted sans',
                          fontWeight: FontWeight.w100,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          left: S.X_RATIO * 20,
                          bottom: S.Y_RATIO * 12,
                        ),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),

                  // 검색 아이콘
                  Positioned(
                    left: 250 * S.X_RATIO,
                    top: (40 - 20) / 2,  // Container 높이(40)에서 아이콘 높이(20) 빼고 /2
                    child: GestureDetector(
                      onTap: _onSearch,
                      child: SvgPicture.asset(
                        'assets/ban/search.svg',
                        height: 20 * S.Y_RATIO,
                        width: 20 * S.X_RATIO,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 1) 검색 결과용 박스 위젯 (RecentBox1과 동일 UI)
class SearchResultBox extends StatelessWidget {
  final String teamName;
  final int teamId;
  final VoidCallback onTap;

  const SearchResultBox({
    super.key,
    required this.teamName,
    required this.teamId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: S.Y_RATIO * 65,
            width: S.X_RATIO * 285,
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                            width: 40*S.Y_RATIO,
                            height: 40*S.Y_RATIO,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(300.0),
                              child: SvgPicture.asset(
                                'assets/ban/teamprofile.svg',
                                fit: BoxFit.cover,
                              ),)
                        ),
                      ),
                      SizedBox(width: 11 * S.X_RATIO),

                        Container(


                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    teamName,
                                    style: TextStyle(
                                      fontSize: 18 * S.Y_RATIO,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Wanted sans',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                    ],
                  ),

                ],
              ),

          ),
        ),
      ],
    );
  }
}


/// 최근 검색 기록 박스 (query와 콜백을 전달받음)
class RecentBox1 extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RecentBox1({
    super.key,
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: S.Y_RATIO * 65,
            width: S.X_RATIO * 320,
            child: Stack(
              children: [
                Row(
                  children: [
                     SizedBox(
                        width: 40*S.Y_RATIO,
                        height: 40*S.Y_RATIO,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(300.0),
                          child: SvgPicture.asset(
                            'assets/ban/teamprofile.svg',
                            fit: BoxFit.cover,
                          ),)
                    ),
                    SizedBox(width: 11 * S.X_RATIO),
                    Text(
                      query,
                      style: TextStyle(
                        fontSize: 18 * S.Y_RATIO,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Wanted sans',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                Positioned(
                  right: 0 * S.X_RATIO,
                  child: IconButton(
                    icon: Icon(Icons.cancel_outlined,
                        size: 24 * S.Y_RATIO, color: Colors.white),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
