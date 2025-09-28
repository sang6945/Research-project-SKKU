// ignore_for_file: camel_case_types, library_private_types_in_public_api, unused_result, deprecated_member_use

import 'package:fineplay/main.dart';
import 'package:fineplay/presentation/viewmodel/home_provider.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:fineplay/services/team_info_service.dart';
import 'package:fineplay/utils/navibar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tuple/tuple.dart' show Tuple3;
import 'package:fineplay/presentation/viewmodel/new_notification_provider.dart';

import '../../viewmodel/myteam_list_provider.dart';

class Team_view extends ConsumerStatefulWidget {
  const Team_view({super.key});

  @override
  ConsumerState<Team_view> createState() => _TeamViewState();
}


class _TeamViewState extends ConsumerState<Team_view> {
  @override
  void initState() {
    super.initState();
    // ★ 화면 진입 시 팀 리스트 캐시 무효화
    Future.microtask(() {
      ref.invalidate(myTeamListProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    // ▶ Provider에서 실시간 상태 읽기
    // 1) SSE로부터 온 새 알림 여부
     final bool hasNewSse = ref.watch(newNotificationProvider);
    // 2) 팀 리스트 API에서 내려준 읽지 않은 알림 플래그
    final teamListResultAsync = ref.watch(myTeamListProvider);
    final bool hasNewFromList =
        teamListResultAsync.asData?.value.hasUnreadNotification ?? false;

    // 3) 둘 중 하나라도 true 면 빨간 알림 아이콘
    final bool showRedIcon = hasNewSse || hasNewFromList;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70 * S.Y_RATIO,
        title: Padding(
            padding:
            EdgeInsets.only(top: 20 * S.Y_RATIO, left: 10 * S.X_RATIO),
            child: GestureDetector(
              onTap: () {
                // 1) selectedIndexProvider 상태를 2(홈)로 바꿔서 탭 전환
                ref.read(selectedIndexProvider.notifier).state = 2;

                // 2) 홈 화면 데이터 리프레시 (home_provider 에 정의된 provider)
                final userId = ref.read(userIdProvider)!;
                ref.invalidate(homeProvider(userId));
              },
              child: Text(
                "Fine Play",
                style: TextStyle(
                  fontSize: 15 * S.Y_RATIO,
                  fontFamily: 'GiantsInline',
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF7E1D),
                ),
              ),
            )),
        backgroundColor: const Color(0xFF030319),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              top: 20 * S.Y_RATIO,
            ),
            child: IconButton(
              icon: showRedIcon
              // newNotification == true → 빨간 알림 아이콘
                  ? SvgPicture.asset(
                'assets/ban/notification_red.svg',
                width: 22 * S.Y_RATIO,
                height: 22 * S.Y_RATIO,
              )
              // false → 기본 아이콘
                  : SvgPicture.asset(
                'assets/ban/notification.svg',
                width: 22 * S.Y_RATIO,
                height: 22 * S.Y_RATIO,
              ),
              onPressed: () {
                 ref.read(newNotificationProvider.notifier).state = false;
                 context.push("/notification");
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20 * S.Y_RATIO,
              right: 30 * S.X_RATIO,
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                size: 23 * S.Y_RATIO,
                color: Colors.white,
              ),
              onPressed: () {
                context.push('/setting');
              },
            ),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            FindingWidget(),
            TeamMakeWidget(),
            MyTeamWidget()

          ],
        ),
      ),
      backgroundColor: const Color(0xFF030319),
    );
  }
}
class FindingWidget extends ConsumerWidget {
  const FindingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(top: S.Y_RATIO * 15),
      child: Center(
        child: GestureDetector(
          onTap: () {
           context.push("/findingteam");
          },
          child: Container(
            height: 40 * S.Y_RATIO,
            width: 300 * S.X_RATIO,
            padding: EdgeInsets.symmetric(horizontal: 20 * S.X_RATIO),
            decoration: BoxDecoration(
              color: const Color(0xFF21213D),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '찾고 있는 팀이 있으신가요?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12 * S.Y_RATIO,
                      fontFamily: 'Wanted sans',
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/ban/search.svg',
                  height: 20,
                  width: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class TeamMakeWidget extends ConsumerStatefulWidget{
  const TeamMakeWidget({super.key});

  @override
  _TeamMakeWidgetState createState() => _TeamMakeWidgetState();
}

class _TeamMakeWidgetState extends ConsumerState<TeamMakeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 22 * S.Y_RATIO),
        Container(
          height: S.Y_RATIO * 54,
          width: S.X_RATIO * 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(S.Y_RATIO * 0),
          ),
          child: Row(
            children: [
              SizedBox(
                width: S.X_RATIO * 158, // 적절한 너비를 설정
                child: Stack(
                  children: [
                    Positioned(
                      top: 10 * S.Y_RATIO, // 상단에서 10만큼 띄움
                      left: 0, // 왼쪽 정렬
                      child: Text(
                        "팀 만들기",
                        style: TextStyle(
                          color: const Color(0xFFC1C1C1),
                          fontSize: 14 * S.Y_RATIO,
                          fontFamily: 'Wanted Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, // 하단에 배치
                      left: 0, // 왼쪽 정렬
                      child: Text(
                        "나만의 팀을 만들어 보세요!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12 * S.Y_RATIO,
                          fontFamily: 'Wanted Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () { context.push("/makingteam");},
                child: Container(
                  width: S.X_RATIO * 140,
                  height: S.Y_RATIO * 44,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF21213D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '팀 만들기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12*S.Y_RATIO,
                        fontFamily: 'Wanted Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class MyTeamWidget extends ConsumerStatefulWidget {
  const MyTeamWidget({super.key});

  @override
  _MyTeamWidgetState createState() => _MyTeamWidgetState();
}

class _MyTeamWidgetState extends ConsumerState<MyTeamWidget> with RouteAware{


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 이 위젯이 속한 Route를 구독
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 뒤에서 돌아왔을 때 (popNext) 호출됩니다.
  @override
  void didPopNext() {
    // 프로바이더를 강제로 새로고침
    ref.refresh(myTeamListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final teamListAsync = ref.watch(myTeamListProvider);
    final String userToken= ref.watch(tokenProvider);
    final int userId= ref.watch(userIdProvider)!;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 48 * S.Y_RATIO),
          child: Center(
            child: SizedBox(
              width: S.X_RATIO * 300,
              child: Text(
                "마이 팀",
                style: TextStyle(
                    fontSize: 14 * S.Y_RATIO,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Wanted Sans',
                    color: const Color(0xFFc1c1c1)),
              ),
            ),
          ),
        ),
        Container(
          height: S.Y_RATIO * 2.0,
          width: S.X_RATIO * 300,
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 10.0 * S.Y_RATIO),
        ),
        teamListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (result) {
            final teams = result.data;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final teamInfoAsync = ref.watch(
                    teamInfoProvider(Tuple3(userToken, userId, team.teamId)));

                return teamInfoAsync.when(
                  loading: () {
                    // 팀 정보가 로딩 중일 때: 빈 컨테이너나 스켈레톤
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8 * S.Y_RATIO),
                      height: 120 * S.Y_RATIO,
                      width: S.X_RATIO * 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15 * S.Y_RATIO),
                      ),
                    );
                  },
                  error: (err, _) {
                    // 오류 났을 때 간단히 에러 표시
                    return const Center(
                      child: Text('팀 정보를 불러올 수 없습니다',
                          style: TextStyle(color: Colors.red, fontFamily: 'Wanted Sans',)),
                    );
                  },
                  data: (info) {
                    return GestureDetector(
                      onTap: () {
                        // Handle tap (for navigating to the team view)
                        context.pushNamed(
                          'myteam',

                          pathParameters: {'teamId': team.teamId.toString()},
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            height: S.Y_RATIO * 120,
                            width: S.X_RATIO * 300,
                            decoration: BoxDecoration(
                              color: const Color(0xFF21213F),
                              borderRadius: BorderRadius.circular(
                                  S.Y_RATIO * 15.0),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 22 * S.X_RATIO,),
                                  child: SizedBox(
                                    width: 63 * S.Y_RATIO,
                                    height: S.Y_RATIO * 120,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 29 * S.Y_RATIO,
                                              bottom: 10 * S.Y_RATIO),
                                          child: SizedBox(
                                            height: S.Y_RATIO * 44,
                                            width: S.Y_RATIO * 44,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(15.0),
                                              child: team.teamImg.isNotEmpty
                                              // if we have a URL, show it; on error, fall back to SVG
                                                  ? Image.network(
                                                team.teamImg,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) =>
                                                    SvgPicture.asset(
                                                      'assets/ban/teamprofile.svg',
                                                      fit: BoxFit.cover,
                                                    ),
                                              )
                                              // otherwise show default SVG
                                                  : SvgPicture.asset(
                                                'assets/ban/teamprofile.svg',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          team.teamName,
                                          textAlign: TextAlign.center,
                                          // Display the team name dynamically
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12 * S.Y_RATIO,
                                            fontFamily: 'Wanted Sans',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 108 * S.X_RATIO,
                                              top: 20 * S.Y_RATIO,
                                              bottom: 8 * S.Y_RATIO),
                                          child: SizedBox(
                                            width: 50 * S.X_RATIO,
                                            height: 60   * S.Y_RATIO,
                                            child: Column(
                                              children: [
                                                Text(
                                                  'OVR',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14 * S.Y_RATIO,
                                                    fontFamily: 'Wanted Sans',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: S.Y_RATIO * 8),
                                                Container(
                                                  width: 50 * S.X_RATIO,
                                                  height: 30 * S.Y_RATIO,
                                                  decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(10),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      team.ovr,
                                                      // Display OVR dynamically
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                        color: const Color(
                                                            0xFF21213F),
                                                        fontSize: 16 *
                                                            S.Y_RATIO,
                                                        fontFamily: 'Wanted Sans',
                                                        fontWeight: FontWeight
                                                            .w600,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 12 * S.X_RATIO,
                                              top: 20 * S.Y_RATIO,
                                              bottom: 8 * S.Y_RATIO),
                                          child: SizedBox(
                                            width: 100 * S.X_RATIO,
                                            height: 60 * S.Y_RATIO,
                                            child: Column(
                                              children: [
                                                Text(
                                                  '최근 전적',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14 * S.Y_RATIO,
                                                    fontFamily: 'Wanted Sans',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: S.Y_RATIO * 8),
                                                Container(
                                                  width: 100 * S.X_RATIO,
                                                  height: 30 * S.Y_RATIO,
                                                  decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(10),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,    // 자식 Text가 넘치면 축소
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        '${teamInfoAsync.value!.totalWin}W / '
                                                            '${teamInfoAsync.value!.totalDraw}D / '
                                                            '${teamInfoAsync.value!.totalLose}L',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          color: const Color(0xFF21213F),
                                                          fontSize: 14 * S.Y_RATIO,  // 기본 텍스트 사이즈
                                                          fontFamily: 'Wanted Sans',
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 111 * S.X_RATIO),
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(text: '#${team.homeTown1}'),
                                                WidgetSpan(
                                                  alignment: PlaceholderAlignment.middle,
                                                  child: SizedBox(width: 10 * S.X_RATIO),
                                                ),
                                                TextSpan(text: '#${team.memberNum}인'),
                                                WidgetSpan(
                                                  alignment: PlaceholderAlignment.middle,
                                                  child: SizedBox(width: 10 * S.X_RATIO),
                                                ),
                                                TextSpan(text: '#${team.sports}'),
                                              ],
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12 * S.Y_RATIO,
                                              fontFamily: 'Wanted Sans',
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: S.Y_RATIO * 10,
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
        ),
      ],
    );
  }
}