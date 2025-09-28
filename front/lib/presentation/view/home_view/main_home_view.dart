// ignore_for_file: library_private_types_in_public_api, camel_case_types, deprecated_member_use


import 'package:fineplay/presentation/viewmodel/favorite_user_list_provider.dart';
import 'package:fineplay/presentation/viewmodel/hometeamlist_provider.dart';
import 'package:fineplay/presentation/viewmodel/my_team_info_provider.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/utils/navibar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fineplay/presentation/viewmodel/home_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:fineplay/utils/stat_selector.dart';
import 'package:fineplay/presentation/viewmodel/new_notification_provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class Main_home_view extends ConsumerStatefulWidget {
  const Main_home_view({super.key});

  @override
  _MainHomeViewState createState() => _MainHomeViewState();
}

class _MainHomeViewState extends ConsumerState<Main_home_view> with RouteAware {
  int? userId;
  String? token;

  @override
  void initState() {
    super.initState();
    // 위젯이 build되기 전에 비동기로 초기 호출
    Future.microtask(() {
      final userId = ref.read(userIdProvider);
      final token = ref.read(tokenProvider);
      if (userId != null) {
        // 최초 진입 시 현재 팀 정보 로드
        ref
            .read(myTeamInfoProvider.notifier)
            .loadInitialTeamInfo(userId: userId, token: token);
        ref.invalidate(homeProvider(userId));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (userId != null) {
      ref.invalidate(homeProvider(userId!)); // ✅ 최신화 핵심
      ref.invalidate(hometeamListProvider(userId!));
      ref.invalidate(favoriteUserListProvider);

      ref.read(myTeamInfoProvider.notifier).loadInitialTeamInfo(
            userId: userId!,
            token: token!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
   final bool hasNewSse = ref.watch(newNotificationProvider);

    final homeAsync = ref.watch(homeProvider(userId));
    final bool hasNewFromProfile =
        homeAsync.asData?.value.hasUnreadNotification ?? false;

    // 4) 둘 중 하나라도 true 면 빨간 아이콘
    final bool showRedIcon = hasNewSse || hasNewFromProfile;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70 * S.Y_RATIO,
        title: Padding(
            padding: EdgeInsets.only(top: 20 * S.Y_RATIO, left: 10 * S.X_RATIO),
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
      backgroundColor: const Color(0xFF030319),
      body: homeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('에러: $e',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Wanted sans',
                ))),
        data: (home) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const FindingWidget(),
                const BannerWidget(),
                MyPlayWidget(
                  profileImg: home.profileImg ?? '',
                  position: home.position.isNotEmpty ? home.position : '-',
                  // null-safe
                  ovr: home.ovr.isNotEmpty ? home.ovr : '0',
                  stats: home.stats,
                  userName: home.userName.isNotEmpty ? home.userName : '익명',
                  selectedStat:
                      home.selectedStat.isNotEmpty ? home.selectedStat : '-',
                ),
                const MyTeamWidget(),
                const FavoritePlayerWidget()
              ],
            ),
          );
        },
      ),
    );
  }
}

class FindingWidget extends ConsumerWidget {
  const FindingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);
    return Padding(
      padding: EdgeInsets.only(top: S.Y_RATIO * 15),
      child: Center(
        child: GestureDetector(
          onTap: () {
          context.push("/findinguser");
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
                    '검색어를 입력하세요!',
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

class BannerWidget extends ConsumerStatefulWidget {
  const BannerWidget({super.key});

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends ConsumerState<BannerWidget> {
  int _currentIndex = 0;
  final List<String> _images = [
    'assets/ban/notification.png',
    'assets/ban/stat_describe.png',
    'assets/ban/error.png',
  ];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 5초 간격으로 이미지 전환
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onBannerTap(BuildContext context) async {
    if (_currentIndex == 0) {
      // 내부 라우트 이동 예시

      context.push("/noticelist");
    } else if (_currentIndex == 1) {
      // 외부 URL 이동 예시

      const url = 'https://fine-play.notion.site/stat-guide';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } else if (_currentIndex == 2) {
      // 다른 페이지 또는 URL 이동 등의 추가 동작 처리

      const url = 'https://fine-play.notion.site/bug-fix';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: S.Y_RATIO * 34.5),
          child: Center(
            child: Container(
              height: S.Y_RATIO * 178,
              width: S.X_RATIO * 298,
              decoration: BoxDecoration(
                color: const Color(0xFF030319),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _onBannerTap(context),
                      child: AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        child: Center(
                          child: FittedBox(
                            child: Image.asset(
                              _images[_currentIndex],
                              key: ValueKey<int>(_currentIndex),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    ),
                    // Positioned(
                    //   bottom: 6,
                    //   right: 6,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 12, vertical: 1),
                    //     decoration: BoxDecoration(
                    //       color: Colors.black54,
                    //       borderRadius: BorderRadius.circular(50),
                    //     ),
                    //     child: Text(
                    //       '${_currentIndex + 1}/${_images.length}',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 12 * S.Y_RATIO,
                    //         fontFamily: 'Wanted sans',
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MyPlayWidget extends ConsumerWidget {
  final String userName;
  final String position;
  final String ovr;
  final String selectedStat;
  final String profileImg;
  final Map<String, dynamic> stats;

  const MyPlayWidget({
    super.key,
    required this.userName,
    required this.position,
    required this.ovr,
    required this.profileImg,
    required this.selectedStat,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    final statList = selectMainStatsAsText(
      selectedStat: selectedStat,
      position: position,
      stats: stats,
    );

    Color getPositionColor(String position) {
      if (position.toUpperCase() == 'MF') {
        return const Color(0xFF00D68F).withOpacity(0.8);
      } else if (position.toUpperCase() == 'DF') {
        return const Color(0xFF3028FF).withOpacity(0.8);
      } else {
        return const Color(0xFFFF381E).withOpacity(0.8);
      }
    }

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 48 * S.Y_RATIO),
          child: Center(
            child: SizedBox(
              width: S.X_RATIO * 300,
              child: Text(
                "마이 플레이",
                style: TextStyle(
                    fontSize: 14 * S.Y_RATIO,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Wanted sans',
                    color: const Color(0xFFc1c1c1)),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: S.Y_RATIO * 76),
          child: Center(
            child: Container(
              height: S.Y_RATIO * 180,
              width: S.X_RATIO * 300,
              decoration: BoxDecoration(
                color: const Color(0xFF21213F),
                borderRadius: BorderRadius.circular(S.Y_RATIO * 15.0),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20 * S.X_RATIO,
                    top: 65 * S.Y_RATIO,
                    child: SizedBox(
                      width: 70 * S.X_RATIO, // 네모박스와 동일한 너비
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ② 네모박스
                          SizedBox(
                            height: S.Y_RATIO * 44,
                            width: S.Y_RATIO * 44,

                            // With this simpler, null-safe version:
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: profileImg.isNotEmpty
                                  // if we have a URL, show it; on error, fall back to SVG
                                  ? Image.network(
                                      profileImg,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              SvgPicture.asset(
                                        'assets/ban/userprofile.svg',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  // otherwise show default SVG
                                  : SvgPicture.asset(
                                      'assets/ban/userprofile.svg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          SizedBox(height: 4 * S.Y_RATIO),
                          // ③ 텍스트
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // 한 줄(maxLines:1)로 그려보고
                              final tp = TextPainter(
                                text: TextSpan(
                                  text: userName,
                                  style: TextStyle(
                                    fontSize: 12 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                  ),
                                ),
                                maxLines: 2,
                                textDirection: TextDirection.ltr,
                              )..layout(maxWidth: constraints.maxWidth);
                              // 한 줄로 안 들어가면 크기를 10으로
                              final fontSize = tp.didExceedMaxLines
                                  ? 10 * S.Y_RATIO
                                  : 12 * S.Y_RATIO;
                              return Text(
                                userName,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontFamily: 'Wanted sans',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 100 * S.X_RATIO,
                      top: 20 * S.Y_RATIO,
                    ),
                    child: SizedBox(
                      width: S.X_RATIO * 72,
                      child: Column(
                        children: [
                          Container(
                            height: S.Y_RATIO * 29,
                            width: S.X_RATIO * 53,
                            decoration: BoxDecoration(
                              color: getPositionColor(position),
                              borderRadius:
                                  BorderRadius.circular(S.Y_RATIO * 10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(position.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: S.Y_RATIO * 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Wanted sans',
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(height: S.Y_RATIO * 13),
                          Container(
                            height: S.Y_RATIO * 27,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(S.Y_RATIO * 5.0),
                              color: const Color(0xFF31315B),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  statList.isNotEmpty ? statList[0] : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: S.Y_RATIO * 9),
                          Container(
                            height: S.Y_RATIO * 27,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(S.Y_RATIO * 5.0),
                              color: const Color(0xFF31315B),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  statList.isNotEmpty ? statList[1] : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: S.Y_RATIO * 9),
                          Container(
                            height: S.Y_RATIO * 27,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(S.Y_RATIO * 5.0),
                              color: const Color(0xFF31315B),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  statList.isNotEmpty ? statList[2] : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 200 * S.X_RATIO,
                      top: 20 * S.Y_RATIO,
                    ),
                    child: SizedBox(
                      width: S.X_RATIO * 72,
                      child: Column(
                        children: [
                          Container(
                            height: S.Y_RATIO * 29,
                            width: S.X_RATIO * 53,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(S.Y_RATIO * 10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  ovr,
                                  style: TextStyle(
                                    color: const Color(0xff21213F),
                                    fontSize: 20 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: S.Y_RATIO * 13),
                          Container(
                            height: S.Y_RATIO * 27,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(S.Y_RATIO * 5.0),
                              color: const Color(0xFF31315B),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  statList.isNotEmpty ? statList[3] : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: S.Y_RATIO * 9),
                          Container(
                            height: S.Y_RATIO * 27,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(S.Y_RATIO * 5.0),
                              color: const Color(0xFF31315B),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  statList.isNotEmpty ? statList[4] : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: S.Y_RATIO * 9),
                          Container(
                            height: S.Y_RATIO * 27,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(S.Y_RATIO * 5.0),
                              color: const Color(0xFF31315B),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  statList.isNotEmpty ? statList[5] : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

class MyTeamWidget extends ConsumerStatefulWidget {
  const MyTeamWidget({super.key});

  @override
  _MyTeamWidgetState createState() => _MyTeamWidgetState();
}

class _MyTeamWidgetState extends ConsumerState<MyTeamWidget> {
  bool _isDropdownOpen = false;
  Color _iconColor = Colors.white;

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      _iconColor = _isDropdownOpen ? const Color(0xFFFF7E1D) : Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    final teamInfo = ref.watch(myTeamInfoProvider);

    return Stack(
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
                    fontFamily: 'Wanted sans',
                    color: const Color(0xFFc1c1c1)),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: S.Y_RATIO * 76),
          child: Center(
            child: Container(
              height: S.Y_RATIO * 180,
              width: S.X_RATIO * 300,
              decoration: BoxDecoration(
                color: const Color(0xFF21213F),
                borderRadius: BorderRadius.circular(S.Y_RATIO * 15.0),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20 * S.X_RATIO,
                    top: 65 * S.Y_RATIO,
                    child: SizedBox(
                      width: 70 * S.X_RATIO, // 네모박스와 동일한 너비
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ② 네모박스
                          Container(
                              height: S.Y_RATIO * 44,
                              width: S.Y_RATIO * 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: teamInfo?.teamImg != null &&
                                        teamInfo!.teamImg!.isNotEmpty
                                    ? Colors.transparent
                                    : Colors.transparent,
                              ),
                              child: teamInfo?.teamImg != null &&
                                      teamInfo!.teamImg!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(15.0),
                                      child: Image.network(
                                        teamInfo.teamImg ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return SvgPicture.asset(
                                            'assets/ban/teamprofile.svg',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(15.0),
                                      child: SvgPicture.asset(
                                        'assets/ban/teamprofile.svg',
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                          SizedBox(height: 4 * S.Y_RATIO),
                          // ③ 텍스트
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final name = teamInfo?.currentTeam ?? 'name';
                              // 한 줄(maxLines:1)로 그려보고
                              final tp = TextPainter(
                                text: TextSpan(
                                  text: name,
                                  style: TextStyle(
                                    fontSize: 12 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                  ),
                                ),
                                maxLines: 2,
                                textDirection: TextDirection.ltr,
                              )..layout(maxWidth: constraints.maxWidth);
                              // 한 줄로 안 들어가면 크기를 10으로
                              final fontSize = tp.didExceedMaxLines
                                  ? 10 * S.Y_RATIO
                                  : 12 * S.Y_RATIO;
                              return Text(
                                name,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontFamily: 'Wanted sans',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 75 * S.X_RATIO,
                      top: 20 * S.Y_RATIO,
                    ),
                    height: 60 * S.Y_RATIO,
                    alignment: Alignment.topCenter,
                    child: Text(
                      "${teamInfo?.win ?? '0'}W | ${teamInfo?.draw ?? '0'}D | ${teamInfo?.lose ?? '0'}L",
                      style: TextStyle(
                        fontSize: 16 * S.Y_RATIO,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Wanted sans',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 100 * S.X_RATIO, top: 10 * S.Y_RATIO),
                    child: SizedBox(
                      width: S.X_RATIO * 72,
                      child: Column(
                        children: [
                          SizedBox(
                            height: S.Y_RATIO * 29,
                            width: S.X_RATIO * 53,
                          ),
                          SizedBox(
                            height: S.Y_RATIO * 13,
                          ),
                          Container(
                            height: S.Y_RATIO * 28,
                            width: S.X_RATIO * 52,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(S.Y_RATIO * 10.0),
                                color: const Color(0xFFFF381E).withOpacity(0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0, 7),
                                  )
                                ]),
                            child: Center(
                              child: FittedBox(
                                child: Text("FW",
                                    style: TextStyle(
                                        fontSize: S.Y_RATIO * 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Wanted sans',
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: S.Y_RATIO * 11,
                          ),
                          Container(
                            height: S.Y_RATIO * 28,
                            width: S.X_RATIO * 52,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(S.Y_RATIO * 10.0),
                                color: const Color(0xFF00D68F).withOpacity(0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0, 7),
                                  )
                                ]),
                            child: Center(
                              child: FittedBox(
                                child: Text("MF",
                                    style: TextStyle(
                                        fontSize: S.Y_RATIO * 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Wanted sans',
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: S.Y_RATIO * 11,
                          ),
                          Container(
                            height: S.Y_RATIO * 28,
                            width: S.X_RATIO * 52,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(S.Y_RATIO * 10.0),
                                color: const Color(0xFF3028FF).withOpacity(0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0, 7),
                                  )
                                ]),
                            child: Center(
                              child: FittedBox(
                                child: Text("DF",
                                    style: TextStyle(
                                        fontSize: S.Y_RATIO * 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Wanted sans',
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 190 * S.X_RATIO, top: 10 * S.Y_RATIO),
                    child: SizedBox(
                      width: S.X_RATIO * 76,
                      child: Column(
                        children: [
                          SizedBox(
                            height: S.Y_RATIO * 29,
                            width: S.X_RATIO * 53,
                          ),
                          SizedBox(
                            height: S.Y_RATIO * 13,
                          ),
                          Container(
                            height: S.Y_RATIO * 28,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(S.Y_RATIO * 5.0),
                                color:
                                    const Color(0xFF585893).withOpacity(0.51),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0, 7),
                                  )
                                ]),
                            child: Center(
                              child: FittedBox(
                                child: Text("${teamInfo?.fw ?? '0'} / 90",
                                    style: TextStyle(
                                        fontSize: 12 * S.Y_RATIO,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Wanted sans',
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: S.Y_RATIO * 11,
                          ),
                          Container(
                            height: S.Y_RATIO * 28,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(S.Y_RATIO * 5.0),
                                color:
                                    const Color(0xFF585893).withOpacity(0.51),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0, 7),
                                  )
                                ]),
                            child: Center(
                              child: FittedBox(
                                child: Text("${teamInfo?.mf ?? '0'} / 90",
                                    style: TextStyle(
                                        fontSize: 12 * S.Y_RATIO,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Wanted sans',
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: S.Y_RATIO * 11,
                          ),
                          Container(
                            height: S.Y_RATIO * 28,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(S.Y_RATIO * 5.0),
                                color:
                                    const Color(0xFF585893).withOpacity(0.51),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0, 7),
                                  )
                                ]),
                            child: Center(
                              child: FittedBox(
                                child: Text("${teamInfo?.df ?? '0'} / 90",
                                    style: TextStyle(
                                        fontSize: 12 * S.Y_RATIO,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Wanted sans',
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Stack(
          children: [
            if (_isDropdownOpen)
              Padding(
                padding:
                    EdgeInsets.only(top: 80 * S.Y_RATIO, left: 250 * S.X_RATIO),
                child: Consumer(
                  builder: (context, ref, _) {
                    final userId = ref.watch(userIdProvider);
                    if (userId == null) return const SizedBox();

                    final teamListAsync =
                        ref.watch(hometeamListProvider(userId));

                    return teamListAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('에러: $e',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Wanted sans',
                          )),
                      data: (teamList) {
                        return teamList.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  '소속된 팀이 없습니다.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                  ),
                                ),
                              )
                            : Container(
                                width: 86 * S.X_RATIO,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: const Color(0xFF21213F),
                                  border: Border.all(
                                      color: const Color(0xFFFF7E1D),
                                      width: 1.8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4.0,
                                      spreadRadius: 0.0,
                                      offset: const Offset(0, 7),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: teamList
                                      .where((team) =>
                                          team['teamName'] != null &&
                                          team['teamId'] != null)
                                      .map((team) {
                                    final teamName = team['teamName'] ?? '팀 없음';
                                    final teamId = team['teamId'];

                                    return GestureDetector(
                                      onTap: () async {
                                        final token = ref.read(tokenProvider);
                                        final userId = ref.read(userIdProvider);

                                        if (userId != null && teamId != null) {
                                          await ref
                                              .read(myTeamInfoProvider.notifier)
                                              .fetchTeamInfo(
                                                  userId: userId,
                                                  teamId: teamId,
                                                  token: token);
                                          setState(() {
                                            _isDropdownOpen = false;
                                            _iconColor = Colors.white;
                                          });
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(7.0),
                                        child: Text(
                                          teamName,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                      },
                    );
                  },
                ),
              ),
            Container(
              padding:
                  EdgeInsets.only(top: 20 * S.Y_RATIO, left: 270 * S.X_RATIO),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 60 * S.Y_RATIO,
                  color: _iconColor,
                ),
                onPressed: _toggleDropdown,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FavoritePlayerWidget extends ConsumerWidget {
  const FavoritePlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    // ① 즐겨찾기 유저 리스트 구독
    final favAsync = ref.watch(favoriteUserListProvider);

    return favAsync.when(
      loading: () => SizedBox(
        height: 140 * S.Y_RATIO,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(
        child: Text(
          '오류: $e',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Wanted sans',
          ),
        ),
      ),
      data: (users) {
        return Column(
          children: [
            // 타이틀
            Container(
              padding: EdgeInsets.only(top: 48 * S.Y_RATIO),
              child: Center(
                child: SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "즐겨찾는 플레이어",
                    style: TextStyle(
                      fontSize: 14 * S.Y_RATIO,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Wanted sans',
                      color: const Color(0xFFc1c1c1),
                    ),
                  ),
                ),
              ),
            ),
            // 자세히 보기 버튼
            Container(
              width: S.X_RATIO * 300,
              padding:
                  EdgeInsets.only(left: 235 * S.X_RATIO, top: 4 * S.Y_RATIO),
              child: GestureDetector(
                onTap: () {
                  context.push("/favorite");
                },
                child: Text(
                  "자세히 보기",
                  style: TextStyle(
                    fontSize: 12 * S.Y_RATIO,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Wanted sans',
                    color: const Color(0xFFc1c1c1),
                  ),
                ),
              ),
            ),
            // 가로 스크롤 리스트
            Padding(
              padding: EdgeInsets.only(top: S.Y_RATIO * 10),
              child: SizedBox(
                width: S.X_RATIO * 300,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 즐겨찾기 유저 카드들
                      for (final u in users) ...[
                        _buildPlayerCard(context, u.nickName, u.userId),
                        SizedBox(width: 15 * S.X_RATIO),
                      ],
                      // 추가 버튼 카드
                      GestureDetector(
                        onTap: () {
                        context.push("/findinguser");
                        },
                        child: _buildAddPlayerCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 49 * S.Y_RATIO),
          ],
        );
      },
    );
  }
}

Widget _buildPlayerCard(BuildContext context, String name, int id) {
  S.init(context);

  return GestureDetector(
    onTap: () {
      context.push('/mypage/$id');

    },
    child: Container(
      height: S.Y_RATIO * 140,
      width: S.X_RATIO * 90,
      decoration: BoxDecoration(
        color: const Color(0xFF21213F),
        borderRadius: BorderRadius.circular(S.Y_RATIO * 15.0),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 17 * S.Y_RATIO),
            FittedBox(
              child: SizedBox(
                  width: 60*S.Y_RATIO,
                  height: 60*S.Y_RATIO,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(300.0),
                    child: SvgPicture.asset(
                      'assets/ban/userprofile.svg',
                      fit: BoxFit.cover,
                    ),)
              ),
            ),
            SizedBox(height: 9 * S.Y_RATIO),
            FittedBox(
              child: Text(
                name,
                style: TextStyle(
                    fontSize: 12 * S.Y_RATIO,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Wanted sans',
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildAddPlayerCard() {
  return Container(
    height: S.Y_RATIO * 140,
    width: S.X_RATIO * 90,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(S.Y_RATIO * 15.0),
      border:
          Border.all(color: const Color(0xFF21213F), width: 3.0 * S.Y_RATIO),
    ),
    child: Center(
      child: Column(
        children: [
          SizedBox(height: 17 * S.Y_RATIO),
          FittedBox(
            child: SvgPicture.asset(
              'assets/ban/plusicon.svg',
              height: 48 * S.Y_RATIO,
              width: 48 * S.X_RATIO,
            ),
          ),
          SizedBox(height: 16 * S.Y_RATIO),
          FittedBox(
            child: Text(
              "즐겨찾는\n플레이어를\n추가해보세요!",
              style: TextStyle(
                fontSize: 12 * S.Y_RATIO,
                fontWeight: FontWeight.w400,
                height: 1.3,
                fontFamily: 'Wanted sans',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
