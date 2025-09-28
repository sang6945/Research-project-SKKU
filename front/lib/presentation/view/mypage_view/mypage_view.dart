// ignore_for_file: deprecated_member_use, camel_case_types

import 'package:fineplay/presentation/viewmodel/home_provider.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:fineplay/utils/navibar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:radar_chart/radar_chart.dart';
// ✅ JSON 파싱
// ✅ 기본 위젯
// ✅ 상태 관리 (API 연동)
// ✅ API 호출
// ✅ 페이지 이동
// ✅ iOS 스타일 UI
// ✅ 화면 비율 조정
// ✅ SVG 이미지
// ✅ 알림 페이지
// ✅ 설정 페이지
import 'package:fineplay/services/mypage_service.dart'; // ✅ 마이페이지 API 서비스 추가
import 'package:tuple/tuple.dart';
import 'package:fineplay/presentation/viewmodel/new_notification_provider.dart';

// 📌 tuple 패키지 import 추가
import 'package:shared_preferences/shared_preferences.dart'; // 추가


class Mypage_view extends ConsumerStatefulWidget {
  final int? userIdArg;

  const Mypage_view({
    super.key,
    this.userIdArg,
  });

  @override
  ConsumerState<Mypage_view> createState() => _MypageViewState();
}

class _MypageViewState extends ConsumerState<Mypage_view> {
  late final int currentUserId;
  late final String userToken;

  @override
  void initState() {
    super.initState();

    currentUserId = widget.userIdArg ?? ref.read(userIdProvider)!;
    userToken = ref.read(tokenProvider);
    // 마이페이지에 진입할 때마다 캐시 무효화
    Future.microtask(() {
      ref.invalidate(mypageProvider(Tuple2(currentUserId, userToken)));
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    // ▶ Provider에서 실시간 상태 읽기

    final int loggedInUserId = ref.read(userIdProvider)!;
    final bool isOwnProfile = widget.userIdArg == null || widget.userIdArg == loggedInUserId;

    // 1) SSE로 감지된 새 알림 플래그
    final bool hasNewSse = ref.watch(newNotificationProvider);
    final mypageData =
        ref.watch(mypageProvider(Tuple2(currentUserId, userToken)));
    // 3) 프로필에서 내려준 읽지 않은 알림 플래그 (data 가 있으면, 없으면 false)
     final bool hasNewFromProfile = mypageData.asData?.value.hasUnreadNotification ?? false;
    // 4) 둘 중 하나라도 true 면 빨간 아이콘
    final bool showRedIcon = isOwnProfile &&(hasNewSse || hasNewFromProfile);

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
          if (isOwnProfile)
            Padding(
              padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
              child: IconButton(
                icon: showRedIcon
                    ? SvgPicture.asset('assets/ban/notification_red.svg', width: 22 * S.Y_RATIO, height: 22 * S.Y_RATIO)
                    : SvgPicture.asset('assets/ban/notification.svg', width: 22 * S.Y_RATIO, height: 22 * S.Y_RATIO),
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
      body: mypageData.when(
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              MyPlayWidget(profile: profile),
              PlayerStatWidget(
                  profile: profile,
                  userToken: userToken,
                  userId: currentUserId),
              SpecialStatWidget(profile: profile),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("에러 발생: ${err.toString()}")),
      ),
      backgroundColor: const Color(0xFF030319),
    );
  }
}

class MyPlayWidget extends ConsumerWidget {
  // void _onTagClicked(BuildContext context, int teamId, String teamName) {
  //   context.pushNamed(
  //     'searchedteam',
  //
  //     pathParameters: {'teamId': teamId.toString()},
  //   );
  //   // 각 태그 클릭 시 수행할 동작을 정의하세요.
  //   if (kDebugMode) {
  //     print('$teamName 태그 클릭됨');
  //   }
  // }

  final MypageProfile profile; // ✅ 프로필 데이터를 받을 필드 추가

  const MyPlayWidget({super.key, required this.profile}); // ✅ 생성자에서 프로필 데이터 받기

  Color getPositionColor(String position) {
    switch (position.toUpperCase()) {
      // ✅ 대소문자 구분 없이 비교
      case "MF":
        return const Color(0xFF00D68F); // 녹색 (미드필더)
      case "FW":
        return const Color(0xFFda3a25); // 빨간색 (공격수)
      case "DF":
        return const Color(0xFF2d27d9); // 파란색 (수비수)
      case "GK":
        return const Color(0xFFFFea00); // 노란색 (골키퍼)
      default:
        return Colors.grey; // 예외 처리 (알 수 없는 포지션)
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 17 * S.Y_RATIO),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "마이 플레이",
                    style: TextStyle(
                        fontSize: 14 * S.Y_RATIO, fontFamily: 'Wanted sans'),
                  ),
                ),
                // 마이플레이와 박스 사이의 하얀색 줄 추가
                Container(
                  height: S.Y_RATIO * 2.0,
                  width: S.X_RATIO * 300,
                  color: Colors.white,
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0 * S.Y_RATIO), // 간격 조절
                ),
                Container(
                  height: S.Y_RATIO * 140, //???????????????
                  width: S.X_RATIO * 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF21213F),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 36 * S.Y_RATIO,
                        left: 28 * S.X_RATIO,
                        child: SizedBox(
                          width: 70 * S.X_RATIO,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: S.Y_RATIO * 44,
                                  width: S.Y_RATIO * 44,
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(15.0),
                                   child: profile.profileImg.isNotEmpty
                                   // if we have a URL, show it; on error, fall back to SVG
                                       ? Image.network(
                                     profile.profileImg,
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
                                SizedBox(height: 10 * S.Y_RATIO),
                                Text(
                                  profile.userName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 125 * S.X_RATIO,
                          top: 27 * S.Y_RATIO,
                        ),
                        child: SizedBox(
                          width: S.X_RATIO * 53,
                          child: Column(
                            children: [
                              Text(
                                '포지션',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans'),
                              ),
                              SizedBox(height: S.Y_RATIO * 10),
                              Container(
                                height: S.Y_RATIO * 29,
                                width: S.X_RATIO * 53,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: getPositionColor(
                                      profile.position), // ✅ 포지션별 색상 적용
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
                                  child: Text(profile.position.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: S.Y_RATIO * 16,
                                          fontFamily: 'Wanted sans',
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 210 * S.X_RATIO,
                          top: 27 * S.Y_RATIO,
                        ),
                        child: SizedBox(
                          width: S.X_RATIO * 53,
                          child: Column(
                            children: [
                              Text(
                                'OVR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans'),
                              ),
                              SizedBox(height: S.Y_RATIO * 10),
                              Container(
                                height: S.Y_RATIO * 29,
                                width: S.X_RATIO * 53,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
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
                                  child: Text(profile.ovr,
                                      style: TextStyle(
                                          fontSize: S.Y_RATIO * 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Wanted sans',
                                          color: const Color(0xFF21213F))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 120 * S.X_RATIO,
                          top: 98 * S.Y_RATIO,
                        ),
                        child: SizedBox(

                          child: FittedBox(
                            child: Container(
                              padding: EdgeInsets.only(right:10*S.X_RATIO),
                              child: Row(
                                children: [
                                  if (profile.teams.isNotEmpty &&
                                      profile.teams[0].teamName != null &&
                                      profile.teams[0].teamName!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () async {
                                        // 1) 팀 검색 화면으로 이동
                                        await context.pushNamed(
                                          'searchedteam',

                                          pathParameters: {'teamId': profile.teams[0].teamId!.toString()},
                                        );
                                        // 2) 돌아왔을 때 캐시 무효화
                                        final userId = ref.read(userIdProvider)!;
                                        final token = ref.read(tokenProvider);
                                        ref.invalidate(
                                            mypageProvider(Tuple2(userId, token)));
                                      },
                                      child: Text(
                                        '#${profile.teams[0].teamName}', //
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0 * S.Y_RATIO,
                                            fontFamily: 'Wanted sans'),
                                      ),
                                    ),
                                  SizedBox(width: 4.0 * S.X_RATIO),
                                  if (profile.teams.length > 1 &&
                                      profile.teams[1].teamName != null &&
                                      profile.teams[1].teamName!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () async {
                                        // 1) 팀 검색 화면으로 이동
                                        await context.pushNamed(
                                          'searchedteam',

                                          pathParameters: {'teamId': profile.teams[1].teamId!.toString()},
                                        );
                                        // 2) 돌아왔을 때 캐시 무효화
                                        final userId = ref.read(userIdProvider)!;
                                        final token = ref.read(tokenProvider);
                                        ref.invalidate(
                                            mypageProvider(Tuple2(userId, token)));
                                      },
                                      child: Text(
                                        '#${profile.teams[1].teamName}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0 * S.Y_RATIO,
                                            fontFamily: 'Wanted sans'),
                                      ),
                                    ),
                                  SizedBox(width: 4.0 * S.X_RATIO),
                                  if (profile.teams.length > 2 &&
                                      profile.teams[2].teamName != null &&
                                      profile.teams[2].teamName!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () async {
                                        // 1) 팀 검색 화면으로 이동
                                        await context.pushNamed(
                                          'searchedteam',

                                          pathParameters: {'teamId': profile.teams[2].teamId!.toString()},
                                        );
                                        // 2) 돌아왔을 때 캐시 무효화
                                        final userId = ref.read(userIdProvider)!;
                                        final token = ref.read(tokenProvider);
                                        ref.invalidate(
                                            mypageProvider(Tuple2(userId, token)));
                                      },
                                      child: Text(
                                        '#${profile.teams[2].teamName}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0 * S.Y_RATIO, fontFamily: 'Wanted sans'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class PlayerStatWidget extends ConsumerStatefulWidget {
  final MypageProfile profile; // ✅ MypageProfile 데이터 추가
  final String userToken;
  final int userId;

  const PlayerStatWidget({
    super.key,
    required this.profile,
    required this.userToken,
    required this.userId, // ✅ 생성자로 받음
  });

  Map<String, double> _extractFeatureValues(Map<String, dynamic> stats) => {
    "HED": _toDouble(stats["HED"]),
    "FST": _toDouble(stats["FST"]),
    "ACT": _toDouble(stats["ACT"]),
    "OFF": _toDouble(stats["OFF"]),
    "COP": _toDouble(stats["COP"]),
    "PAC": _toDouble(stats["PAC"]),
    "CRO": _toDouble(stats["CRO"]),
    "TEC": _toDouble(stats["TEC"]),
    "PAS": _toDouble(stats["PAS"]),
    "DEC": _toDouble(stats["DEC"]),
    "BLD": _toDouble(stats["BLD"]),
    "DRV": _toDouble(stats["DRV"]),
    "TAC": _toDouble(stats["TAC"]),
    "SHO": _toDouble(stats["SHO"]),
    "DRI": _toDouble(stats["DRI"]),
    "SPD": _toDouble(stats["SPD"]),
  };

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }



  @override
  ConsumerState<PlayerStatWidget> createState() => _PlayerStatWidgetState();
}

class _PlayerStatWidgetState extends ConsumerState<PlayerStatWidget> {
  late List<String> fixedFeatures;
  late Map<String, double> featureValues;
  String selectedFeature = 'CRO';
  late final MypageService mypageService; // ✅ API 호출을 위한 서비스 인스턴스

  Map<String, double> _extractFeatureValues(Map<String, dynamic> stats) => {
    "HED": _toDouble(stats["HED"]),
    "FST": _toDouble(stats["FST"]),
    "ACT": _toDouble(stats["ACT"]),
    "OFF": _toDouble(stats["OFF"]),
    "COP": _toDouble(stats["COP"]),
    "PAC": _toDouble(stats["PAC"]),
    "CRO": _toDouble(stats["CRO"]),
    "TEC": _toDouble(stats["TEC"]),
    "PAS": _toDouble(stats["PAS"]),
    "DEC": _toDouble(stats["DEC"]),
    "BLD": _toDouble(stats["BLD"]),
    "DRV": _toDouble(stats["DRV"]),
    "TAC": _toDouble(stats["TAC"]),
    "SHO": _toDouble(stats["SHO"]),
    "DRI": _toDouble(stats["DRI"]),
    "SPD": _toDouble(stats["SPD"]),
  };

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  @override
  void didUpdateWidget(covariant PlayerStatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldPos = oldWidget.profile.position.toUpperCase();
    final newPos = widget.profile.position.toUpperCase();

    final statsChanged =
    !mapEquals(oldWidget.profile.stats, widget.profile.stats);

    if (newPos != oldPos || statsChanged) {
      setState(() {
        fixedFeatures = getFixedFeatures(newPos);
        featureValues = _extractFeatureValues(widget.profile.stats);
      });
    }

    if (oldWidget.profile.selectedStat != widget.profile.selectedStat) {
      setState(() {
        selectedFeature = widget.profile.selectedStat;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    selectedFeature = widget.profile.selectedStat;
    // ✅ 포지션에 따라 고정 피처 설정
    fixedFeatures = getFixedFeatures(widget.profile.position.toUpperCase());
    mypageService = MypageService(authToken: widget.userToken);
    // ✅ profile.stats에서 실제 데이터 가져오기
    featureValues = {
      "HED": widget.profile.stats["HED"].toDouble(),
      "FST": widget.profile.stats["FST"].toDouble(),
      "ACT": widget.profile.stats["ACT"].toDouble(),
      "OFF": widget.profile.stats["OFF"].toDouble(),
      "COP": widget.profile.stats["COP"].toDouble(),
      "PAC": widget.profile.stats["PAC"].toDouble(),
      "CRO": widget.profile.stats["CRO"].toDouble(),
      "TEC": widget.profile.stats["TEC"].toDouble(),
      "PAS": widget.profile.stats["PAS"].toDouble(),
      "DEC": widget.profile.stats["DEC"].toDouble(),
      "BLD": widget.profile.stats["BLD"].toDouble(),
      "DRV": widget.profile.stats["DRV"].toDouble(),
      "TAC": widget.profile.stats["TAC"].toDouble(),
      "SHO": widget.profile.stats["SHO"].toDouble(),
      "DRI": widget.profile.stats["DRI"].toDouble(),
      "SPD": widget.profile.stats["SPD"].toDouble(),
    };
  }


  /// ✅ 포지션에 따라 고정 피처 리스트 결정
  List<String> getFixedFeatures(String position) {
    switch (position) {
      case "FW":
        return ["SHO", "SPD", "PAS", "PAC", "DRV"];
      case "MF":
        return ["DEC", "SPD", "PAS", "PAC", "DRI"];
      case "DF":
        return ["TAC", "SPD", "PAS", "PAC", "BLD"];
      default:
        return ["SPD", "PAS", "PAC", "DEC", "DRI"];
    }
  }

  final List<String> optionalFeatures = [
    "CRO",
    "HED",
    "FST",
    "ACT",
    "OFF",
    "TEC",
    "COP"
  ]; //개인지표

  void _onFeatureTap(String feature, double value) {
    if (kDebugMode) {
      print('$feature: $value 클릭됨');
    }
    context.push(
      '/statpage',
      extra: {
        "feature": feature,
        "userId": widget.userId, // userId 전달
        "userToken": widget.userToken,
      },
    );
  }

  Future<void> _updateSelectedStat(String feature) async {
    try {
      await mypageService.updateSelectedStat(widget.userId, feature);
      if (kDebugMode) {
        print("스탯 업데이트 성공: $feature");
      }
    } catch (e) {
      if (kDebugMode) {
        print("스탯 업데이트 실패: $e");
      }
    }
  }

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

    final currentUserId = ref.read(userIdProvider)!;
    List<String> displayedFeatures = [selectedFeature, ...fixedFeatures];
    List<double> displayedValues = displayedFeatures
        .map((feature) => featureValues[feature]! / 100)
        .toList();

    return Stack(children: [
      Container(
          padding: EdgeInsets.only(top: 23 * S.Y_RATIO),
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: S.X_RATIO * 300,
              child: Text(
                "플레이어 스탯",
                style: TextStyle(
                    fontSize: 14 * S.Y_RATIO, fontFamily: 'Wanted sans'),
              ),
            ),
            // 마이플레이와 박스 사이의 하얀색 줄 추가
            Container(
              //흰색선
              height: S.Y_RATIO * 2.0,
              width: S.X_RATIO * 300,
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0 * S.Y_RATIO), // 간격 조절
            ),
            Container(
              //바탕
              height: S.Y_RATIO * 420, //수정필요!!
              width: S.X_RATIO * 300,
              decoration: BoxDecoration(
                color: const Color(0xFF21213F),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Stack(children: [
                Column(
                  children: [
                    SizedBox(height: 13.0 * S.Y_RATIO),
                    FittedBox(
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            TextSpan(
                              text: widget.profile.userName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0 * S.Y_RATIO,
                                  // 글자 크기를 더 크게 설정
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Wanted sans'),
                            ),
                            TextSpan(
                              text: ' 님의 OVR은 ',
                              style: TextStyle(
                                  color: const Color(0xFFFFE3CE),
                                  fontSize: 12.0 * S.Y_RATIO,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Wanted sans'),
                            ),
                            TextSpan(
                              text: '상위 ${widget.profile.ovrPercent}%',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0 * S.Y_RATIO,
                                  // 글자 크기를 더 크게 설정
                                  fontWeight: FontWeight.w900,
                                  // 더 두껍게 설정
                                  fontFamily: 'Wanted sans'),
                            ),
                            TextSpan(
                              text: ' 예요🔥',
                              style: TextStyle(
                                  color: const Color(0xFFFFE3CE),
                                  fontSize: 12.0 * S.Y_RATIO,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Wanted sans'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 22.0 * S.Y_RATIO),
                    FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SPECIAL',
                            style: TextStyle(
                                fontSize: 12 * S.Y_RATIO,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Wanted sans'),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  // 내 아이디일 때만 열기, 아니면 null로 둬서 터치 무시
                                  onTap: currentUserId == widget.userId
                                      ? _toggleDropdown
                                      : null, // 드롭다운을 열고 닫는 동작
                                  child: Text(
                                    selectedFeature,
                                    style: TextStyle(
                                        fontSize: 14 * S.Y_RATIO,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Wanted sans'),
                                  ),
                                ),
                                if (currentUserId == widget.userId)
                                  SizedBox(
                                    width: 30 * S.Y_RATIO, // 명시적 크기 설정
                                    height: 30 * S.Y_RATIO,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.arrow_drop_down_rounded,
                                        size: 30 * S.Y_RATIO,
                                        color: _iconColor,
                                      ),
                                      onPressed: _toggleDropdown,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                  ),
                              ]),
                          Text(
                            featureValues[selectedFeature]!.toInt().toString(),
                            style: TextStyle(
                                color: const Color(0xFFFF7400),
                                fontSize: 18.0 * S.Y_RATIO,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Wanted sans'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6 * S.Y_RATIO),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1, // 비율 조정 가능
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FittedBox(
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        double value =
                                            featureValues[fixedFeatures[4]] ??
                                                0.0;
                                        _onFeatureTap(
                                            fixedFeatures[4], value); // 클릭 이벤트 처리
                                      },
                                      child: Column(children: [
                                        //고정4번째 항목
                                        Text(
                                          fixedFeatures[4],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                        Text(
                                          (featureValues[fixedFeatures[4]] ?? 0.0)
                                              .toStringAsFixed(0),
                                          style: TextStyle(
                                              color: const Color(0xFFFF7400),
                                              fontSize: 18.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                      ]),
                                    ),
                                    SizedBox(height: 60 * S.Y_RATIO),
                                    GestureDetector(
                                      onTap: () {
                                        double value =
                                            featureValues[fixedFeatures[3]] ??
                                                0.0;
                                        _onFeatureTap(
                                            fixedFeatures[3], value); // 클릭 이벤트 처리
                                      },
                                      child: Column(children: [
                                        //고정3번째 항목
                                        Text(
                                          fixedFeatures[3],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                        Text(
                                          (featureValues[fixedFeatures[3]] ?? 0.0)
                                              .toStringAsFixed(0),
                                          style: TextStyle(
                                              color: const Color(0xFFFF7400),
                                              fontSize: 18.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                      ]),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        FittedBox(
                          child: SizedBox(
                            height: 206 * S.Y_RATIO,
                            child: FittedBox(
                              child: RadarChart(
                                length: 6,
                                radius: 100 * S.Y_RATIO,
                                //y로 할지 x로 할지
                                initialAngle: (3.14 / 6) * 9,
                                backgroundColor: const Color(0xFF343456),
                                borderStroke: 2,
                                borderColor: const Color(0xFF41415A),
                                radars: [
                                  RadarTile(
                                    values: const [0.75, 0.75, 0.75, 0.75, 0.75, 0.75],
                                    borderStroke: 2,
                                    borderColor: const Color(0xFF59597C),
                                    backgroundColor: const Color(0xFF515172),
                                  ),
                                  RadarTile(
                                    values: const [0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
                                    borderStroke: 2,
                                    borderColor: const Color(0xFF67678A),
                                    backgroundColor: const Color(0xFF626282),
                                  ),
                                  RadarTile(
                                    values: const [0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
                                    borderStroke: 2,
                                    borderColor: const Color(0xFF9E9ED1),
                                    backgroundColor: const Color(0xFF8787B3),
                                  ),
                                  RadarTile(
                                    values: displayedValues,
                                    borderStroke: 2,
                                    borderColor: const Color(0xFFEE650B),
                                    backgroundColor:
                                        const Color(0xFFCA6022).withOpacity(0.8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1, // 비율 조정 가능
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        double value =
                                            featureValues[fixedFeatures[0]] ??
                                                0.0;
                                        _onFeatureTap(
                                            fixedFeatures[0], value); // 클릭 이벤트 처리
                                      },
                                      child: Column(children: [
                                        //고정4번째 항목
                                        Text(
                                          fixedFeatures[0],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                        Text(
                                          (featureValues[fixedFeatures[0]] ?? 0.0)
                                              .toStringAsFixed(0),
                                          style: TextStyle(
                                              color: const Color(0xFFFF7400),
                                              fontSize: 18.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                      ]),
                                    ),
                                    SizedBox(height: 60 * S.Y_RATIO),
                                    GestureDetector(
                                      onTap: () {
                                        double value =
                                            featureValues[fixedFeatures[1]] ??
                                                0.0;
                                        _onFeatureTap(
                                            fixedFeatures[1], value); // 클릭 이벤트 처리
                                      },
                                      child: Column(children: [
                                        //고정3번째 항목
                                        Text(
                                          fixedFeatures[1],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                        Text(
                                          (featureValues[fixedFeatures[1]] ?? 0.0)
                                              .toStringAsFixed(0),
                                          style: TextStyle(
                                              color: const Color(0xFFFF7400),
                                              fontSize: 18.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                      ]),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        double value = featureValues[fixedFeatures[2]] ?? 0.0;
                        _onFeatureTap(fixedFeatures[2], value); // 클릭 이벤트 처리
                      },
                      child: Column(
                        children: [
                          Text(
                            (featureValues[fixedFeatures[2]] ?? 0.0)
                                .toStringAsFixed(0),
                            style: TextStyle(
                                color: const Color(0xFFFF7400),
                                fontSize: 18.0 * S.Y_RATIO,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Wanted sans'),
                          ),
                          Text(
                            fixedFeatures[2],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0 * S.Y_RATIO,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Wanted sans'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isDropdownOpen)
                  Positioned(
                    top: 100 * S.Y_RATIO, // 원하는 위치로 조정
                    left: S.X_RATIO * 360 / 2 -
                        (130 * S.X_RATIO) / 2 +
                        5 * S.X_RATIO, // 화면 중앙에 배치
                    child: Container(
                      width: 60 * S.X_RATIO,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF21213F),
                        border:
                            Border.all(color: const Color(0xFFFF7E1D), width: 1.8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        // 항목 수에 따라 높이가 조정되도록 설정
                        children: optionalFeatures.map((feature) {
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                selectedFeature = feature; // 선택된 항목 업데이트
                                _isDropdownOpen = false; // 드롭다운 닫기
                                _iconColor = Colors.white; // 아이콘 색상 복원
                              });
                              await _updateSelectedStat(feature);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: FittedBox(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16 * S.Y_RATIO,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Wanted sans'),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ]),
            )
          ]))),
    ]);
  }
}

class SpecialStatWidget extends StatefulWidget {
  final MypageProfile profile;

  const SpecialStatWidget({super.key, required this.profile});

  @override
  // ignore: library_private_types_in_public_api
  _SpecialStatWidgetState createState() => _SpecialStatWidgetState();
}

class _SpecialStatWidgetState extends State<SpecialStatWidget> {
  static const Map<String, String> _placeholderAssets = {
    "ACT": "assets/ban/act.png",
    "COP": "assets/ban/cop.png",
    "CRO": "assets/ban/cro.png",
    "FST": "assets/ban/fst.png",
    "HED": "assets/ban/hed.png",
    "OFF": "assets/ban/off.png",
    "TEC": "assets/ban/tec.png",
  };

  List<Map<String, String>> skills = [
    {"name": "CRO", "desc": "cross"},
    {"name": "HED", "desc": "header"},
    {"name": "FST", "desc": "first touch"},
    {"name": "ACT", "desc": "act"},
    {"name": "OFF", "desc": "off the ball"},
    {"name": "TEC", "desc": "technique"},
    {"name": "COP", "desc": "cop"},
  ];

  @override

  void initState() {

    super.initState();

    _restoreSkillOrder();

  }

  Future<void> _saveSkillOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(

        'special_skill_order',

        skills.map((e) => e['name']!).toList()

    );
  }

  Future<void> _restoreSkillOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('special_skill_order');
    if (savedOrder != null && savedOrder.length == skills.length) {
      setState(() {
        skills.sort((a, b) =>

        savedOrder.indexOf(a['name']!) - savedOrder.indexOf(b['name']!)

        );
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    S.init(context);

    // final Map<String, String> imageMap = widget.profile.statImages;
    return Stack(children: [
      Container(
        padding: EdgeInsets.only(top: 23 * S.Y_RATIO),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: S.X_RATIO * 300,
                child: Text(
                  "스페셜 스탯",
                  style: TextStyle(
                      fontSize: 14 * S.Y_RATIO, fontFamily: 'Wanted sans'),
                ),
              ),
              // 하얀색 줄 추가
              Container(
                height: S.Y_RATIO * 2.0,
                width: S.X_RATIO * 300,
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 10.0 * S.Y_RATIO),
              ),
              // 드래그 앤 드롭 리스트
              SizedBox(
                width: S.X_RATIO * 300,
                child: ReorderableListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  // 기본 드래그 핸들 제거
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = skills.removeAt(oldIndex);
                      skills.insert(newIndex, item);
                    });
                    _saveSkillOrder();
                  },
                  shrinkWrap: true,
                  // 부모 크기에 맞춤
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    return _buildSkillCard(skills[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildSkillCard(Map<String, String> skill, int index) {
    final String name = skill["name"]!;
    final Map<String, String> imageMap = widget.profile.statImages;
    final String key = "${skill["name"]}Img"; // 예: "CROImg"
    final String? imageUrl = imageMap[key]; // 실제 이미지 URL

    final String placeholder = _placeholderAssets[name]!;

    return Card(
      key: ValueKey(skill["name"]),
      // 고유한 키 설정
      elevation: 4,
      margin: EdgeInsets.symmetric(
        vertical: 8.0 * S.Y_RATIO,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: const Color(0xFF21213F),
      child: Container(
        width: 300,
        padding: EdgeInsets.symmetric(
          vertical: 16.0 * S.Y_RATIO,
          horizontal: 16.0 * S.X_RATIO,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10.0 * S.X_RATIO),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${skill["name"]} ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans'),
                        ),
                        TextSpan(
                          text: '(${skill["desc"]})',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans'),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 20.0 * S.Y_RATIO,
                  ),
                ),
                SizedBox(width: 10.0 * S.X_RATIO),
              ],
            ),
            Container(
              height: S.Y_RATIO * 2.0,
              width: S.X_RATIO * 250,
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 6.0 * S.Y_RATIO),
            ),
            SizedBox(height: 10 * S.Y_RATIO),
            Container(
              width: 270 * S.X_RATIO,
              height: 160 * S.Y_RATIO,
              //padding: EdgeInsets.all(8.0),//여기도 statpage와 마찬가지로 패딩필요하면 수정필요
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: imageUrl != null && imageUrl.isNotEmpty
                    ? Colors.transparent
                    : Colors.transparent,
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        imageUrl,
                        height: double.infinity, // 세로도 꽉 채움
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              "이미지 로딩 실패",
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      placeholder,
                      height: double.infinity, // 세로도 꽉 채움
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
