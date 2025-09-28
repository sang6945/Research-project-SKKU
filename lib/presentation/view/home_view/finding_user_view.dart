// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
//finding_user_view.dart
import 'dart:convert';
import 'package:fineplay/presentation/viewmodel/favorite_user_list_provider.dart';
import 'package:fineplay/presentation/viewmodel/search_history_provider.dart';
import 'package:fineplay/presentation/viewmodel/user_favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/user_search_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';

// ======================= 뷰 =======================

final deleteAllProvider = StateProvider<bool>((ref) => false);
final isRecentBox1VisibleProvider = StateProvider<bool>((ref) => true);
final isRecentBox2VisibleProvider = StateProvider<bool>((ref) => true);

// ignore: camel_case_types
class Finding_User_view extends ConsumerWidget {
  const Finding_User_view({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    final query = ref.watch(userSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(top: 15.0 * S.Y_RATIO),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              ref.invalidate(favoriteUserListProvider);
              return Navigator.pop(context);
            },
          ),
        ),
        actions: const [
          FindingWidget(),
        ],
        backgroundColor: const Color(0xFF030319),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (query.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(top: S.Y_RATIO * 28),
                child: Center(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final result = ref.watch(userSearchResultProvider(query));

                      return result.when(
                        data: (users) => Column(
                          children: users
                              .map((user) => UserResultBox(
                                  user: user,
                                  onTap: () {
                                    // ✅ 실제 클릭 시에만 기록 저장
                                    ref
                                        .read(userHistoryProvider.notifier)
                                        .add(user.nickName);

                                    context.pushNamed(
                                      'mypage',
                                      pathParameters: {'id': user.userId.toString()},
                                    );
                                  }))
                              .toList(),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text(
                            'Error: $e',
                            style: const TextStyle(color: Colors.white,
                              fontFamily: 'Wanted sans'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: EdgeInsets.only(
                    top: S.Y_RATIO * 28,
                    left: S.X_RATIO * 30,
                    right: S.X_RATIO * 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("최근검색",
                        style: TextStyle(
                          fontFamily: 'Wanted sans',
                          fontSize: 12 * S.Y_RATIO,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        )),
                    GestureDetector(
                      onTap: () {
                        ref.read(userHistoryProvider.notifier).clear();
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
              Consumer(builder: (context, ref, _) {
                final history = ref.watch(userHistoryProvider);
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
                        // 기록 클릭 → 바로 검색
                        ref.read(userSearchQueryProvider.notifier).state = q;
                      },
                      onDelete: () {
                        // 개별 기록 삭제
                        ref.read(userHistoryProvider.notifier).remove(q);
                      },
                    );
                  }).toList(),
                );
              }),
            ],
          ],
        ),
      ),
      backgroundColor: const Color(0xFF030319),
    );
  }
}

class FindingWidget extends ConsumerStatefulWidget {
  const FindingWidget({super.key});

  @override
  _FindingWidgetState createState() => _FindingWidgetState();
}

class _FindingWidgetState extends ConsumerState<FindingWidget> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch() async {
    final nickname = _searchController.text.trim();
    if (nickname.isEmpty) return;

    ref.read(userSearchQueryProvider.notifier).state = nickname;
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: S.Y_RATIO * 15, right: S.X_RATIO * 28),
          child: Center(
            child: Container(
              height: 40,
              width: S.X_RATIO * 280,
              decoration: BoxDecoration(
                color: const Color(0xFF21213d),
                borderRadius: BorderRadius.circular(10.0 * S.Y_RATIO),
              ),
              child: Stack(children: [
                Positioned.fill(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearch(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요!',
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
                  ),
                ),
                Positioned(
                  left: 250 * S.X_RATIO,
                  top: 10,
                  child: GestureDetector(
                    onTap: _onSearch,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/ban/search.svg',
                        height: 20 * S.Y_RATIO,
                        width: 20 * S.X_RATIO,
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ======================= 검색 결과 출력 =======================

class UserResultBox extends ConsumerWidget {
  final UserSummary user;
  final VoidCallback onTap;

  const UserResultBox({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    // 1) 즐겨찾기 여부를 선언적으로 구독
    final favAsync = ref.watch(isUserFavoriteProvider(user.userId));

    return favAsync.when(
      loading: () => /* 로딩 스켈레톤 or 기본 UI */
          Container(
        height: S.Y_RATIO * 65,
        width: S.X_RATIO * 285,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) =>
          // 에러 시 빈별으로 처리
          _buildRow(isStarred: false, context: context, ref: ref),
      data: (isStarred) =>
          _buildRow(isStarred: isStarred, context: context, ref: ref),
    );
  }

  Widget _buildRow({
    required bool isStarred,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: S.Y_RATIO * 65,
        width: S.X_RATIO * 285,
        margin: const EdgeInsets.symmetric(vertical: 4),
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
                    'assets/ban/userprofile.svg',
                    fit: BoxFit.cover,
                  ),)
                ),
                SizedBox(width: 11 * S.X_RATIO),
                Text(
                  user.nickName,
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
              right: 0,
              child: IconButton(
                icon: Icon(
                  isStarred ? Icons.star : Icons.star_border_outlined,
                  size: 25 * S.Y_RATIO,
                  color: const Color(0xFF0A82FF),
                ),
                onPressed: () async {
                  // 2) 토글 API 호출
                  final token = ref.read(tokenProvider);
                  final userId = ref.read(userIdProvider)!;
                  final favId = user.userId;
                  late http.Response resp;

                  if (isStarred) {
                    resp = await http.delete(
                      Uri.parse(
                          'http://localhost:8080/api/favorite/user/delete'),
                      headers: {
                        'Authorization': 'Bearer $token',
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(
                          {'userId': userId, 'favoriteUserId': favId}),
                    );
                  } else {
                    resp = await http.post(
                      Uri.parse('http://localhost:8080/api/favorite/user/add'),
                      headers: {
                        'Authorization': 'Bearer $token',
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(
                          {'userId': userId, 'favoriteUserId': favId}),
                    );
                  }

                  if (resp.statusCode == 200) {
                    // 3) 성공 시 Provider 리프레시
                    ref.invalidate(isUserFavoriteProvider(favId));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('즐겨찾기 오류: ${resp.body}')));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= 최근 검색 박스 예시 =======================
class RecentBox1 extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) query(닉네임)로 검색 API 호출
    final searchAsync = ref.watch(userSearchResultProvider(query));
    S.init(context);


    return searchAsync.when(
      loading: () => Container(
        height: S.Y_RATIO * 65,
        width: S.X_RATIO * 320,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => _buildEmpty(context),
      data: (users) {
        if (users.isEmpty) return _buildEmpty(context);

        final user = users.first;
        // 2) 즐겨찾기 상태 구독
        final favAsync = ref.watch(isUserFavoriteProvider(user.userId));

        return favAsync.when(
          loading: () => _buildEmpty(context),
          error: (_, __) => _buildRow(user, false, context, ref),
          data: (isStarred) =>
              _buildRow(user, isStarred, context, ref),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    S.init(context);

    return GestureDetector(
      onTap:  onTap, // 클릭 무시 or 로직 추가
      child: SizedBox(
        height: S.Y_RATIO * 65,
        width: S.X_RATIO * 320,
        child: Center(
          child: Text(
            query,
            style: TextStyle(
              fontSize: 18 * S.Y_RATIO,
              color: Colors.white,
              fontFamily: 'Wanted sans',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(UserSummary user, bool isStarred, BuildContext context, WidgetRef ref) {
    S.init(context);

    return GestureDetector(
      onTap: () {
        // 클릭 시 바로 마이페이지 이동
        context.pushNamed(
          'mypage',

          pathParameters: {'id': user.userId.toString()},
        );
      },
      child: Container(
        height: S.Y_RATIO * 65,
        width: S.X_RATIO * 320,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // 프로필 아이콘
            SizedBox(
                width: 40*S.Y_RATIO,
                height: 40*S.Y_RATIO,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(300.0),
                  child: SvgPicture.asset(
                    'assets/ban/userprofile.svg',
                    fit: BoxFit.cover,
                  ),)
            ),
            SizedBox(width: 11 * S.X_RATIO),
            // 닉네임
            Expanded(
              child: Text(
                user.nickName,
                style: TextStyle(
                  fontSize: 18 * S.Y_RATIO,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Wanted sans',
                  color: Colors.white,
                ),
              ),
            ),
            // 즐겨찾기 토글
            IconButton(
              icon: Icon(
                isStarred ? Icons.star : Icons.star_border_outlined,
                size: 25 * S.Y_RATIO,
                color: const Color(0xFF0A82FF),
              ),
              onPressed: () async {
                final token = ref.read(tokenProvider);
                final myId = ref.read(userIdProvider)!;
                final favId = user.userId;
                late http.Response resp;

                if (isStarred) {
                  resp = await http.delete(
                    Uri.parse('http://localhost:8080/api/favorite/user/delete'),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({'userId': myId, 'favoriteUserId': favId}),
                  );
                } else {
                  resp = await http.post(
                    Uri.parse('http://localhost:8080/api/favorite/user/add'),
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({'userId': myId, 'favoriteUserId': favId}),
                  );
                }

                if (resp.statusCode == 200) {
                  ref.invalidate(isUserFavoriteProvider(favId));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('즐겨찾기 오류: ${resp.body}'))
                  );
                }
              },
            ),
            // 개별 삭제 버튼
            IconButton(
              icon: Icon(Icons.cancel_outlined,
                  size: 24 * S.Y_RATIO, color: Colors.white),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}