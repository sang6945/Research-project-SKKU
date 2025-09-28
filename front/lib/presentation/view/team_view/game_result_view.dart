// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:radar_chart/radar_chart.dart';
import 'package:tuple/tuple.dart';
import 'package:fineplay/services/team_info_service.dart'; // teamInfoProvider
import 'package:fineplay/services/mypage_service.dart';

class Game_result_view extends ConsumerStatefulWidget {
  final String userToken;
  final int userId;
  final int teamId;
  final int game_num;

  const Game_result_view({
    super.key,
    required this.game_num,
    required this.userId,
    required this.teamId,
    required this.userToken,
  });

  @override
  ConsumerState<Game_result_view> createState() => _GameResultViewState();
}

class _GameResultViewState extends ConsumerState<Game_result_view> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // 캐시 무효화
      ref.invalidate(matchDetailProvider(
        Tuple4(widget.userToken, widget.userId, widget.teamId, widget.game_num),
      ));
      // 즉시 재요청
      ref.read(matchDetailProvider(
        Tuple4(widget.userToken, widget.userId, widget.teamId, widget.game_num),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    final detailAsync = ref.watch(matchDetailProvider(
      Tuple4(widget.userToken, widget.userId, widget.teamId, widget.game_num),
    ));

    return detailAsync.when(
        loading: () => const Scaffold(
              backgroundColor: Color(0xFF030319),
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (err, _) => Scaffold(
              backgroundColor: const Color(0xFF030319),
              body: Center(
                child: Text('매치 정보 로드 실패: $err',
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
        data: (detail) => Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(70 * S.Y_RATIO),
                child: AppBar(
                  automaticallyImplyLeading: false,

                  title: Stack(
                    children: [
                      Align(
                          alignment: Alignment.center, // 중앙에 텍스트 배치
                          child: Padding(
                            padding: EdgeInsets.only(top: 25.0 * S.Y_RATIO),
                            child: Text(
                              "경기 결과", // 제목 텍스트
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0 * S.Y_RATIO,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Wanted sans',
                              ),
                            ),
                          )),
                      Align(
                        alignment: Alignment.centerLeft, // 왼쪽에 뒤로가기 아이콘 배치
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(); // 뒤로가기 기능
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 25.0 * S.Y_RATIO,
                                left: 10.0 * S.X_RATIO), // 왼쪽 여백
                            child: Icon(
                              Icons.arrow_back_ios, // 뒤로가기 아이콘
                              color: Colors.white,
                              size: 20.0 * S.Y_RATIO,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF030319), // AppBar 배경색
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    MatchWidget(
                        userToken: widget.userToken,
                        teamId: widget.teamId,
                        detail: detail,
                        matchId: widget.game_num),
                    FormationWidget(detail: detail),
                    PersonalWidget(
                      detail: detail,
                      userToken: widget.userToken,
                      userId: widget.userId,
                      teamId: widget.teamId,
                      gameNum: widget.game_num,
                    ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF030319),
            ));
  }
}

class MatchWidget extends StatelessWidget {
  final MatchDetail detail;
  final int matchId;
  final String userToken;
  final int teamId;
  const MatchWidget({
    super.key,
    required this.teamId,
    required this.userToken,
    required this.detail,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context) {
    // 홈/어웨이 득점자 리스트 길이 기준
    final homeScorers = detail.homeTeamScorer;
    final awayScorers = detail.awayTeamScorer;
    final maxGoals = homeScorers.length > awayScorers.length
        ? homeScorers.length
        : awayScorers.length;

    return Container(
      padding: EdgeInsets.only(top: 33 * S.Y_RATIO),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 300 * S.X_RATIO,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "경기",
                    style: TextStyle(
                      fontSize: 14 * S.Y_RATIO,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Wanted sans',
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (kDebugMode) {
                        print("경기 결과 카드 클릭됨: matchId=$matchId");
                      }
                      context.push(
                             '/match_detail/'
                                 '$userToken/'
                                 '$teamId/'
                                 '$matchId',
                          );
                    },
                    child: Text(
                      "더보기",
                      style: TextStyle(
                        fontSize: 12 * S.Y_RATIO,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Wanted sans',
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * S.Y_RATIO),
            Container(
              padding: EdgeInsets.only(
                  top: 22 * S.Y_RATIO,
                  left: 18 * S.X_RATIO,
                  right: 18 * S.X_RATIO,
                  bottom: 22 * S.Y_RATIO),
              width: 300 * S.X_RATIO,
              decoration: BoxDecoration(
                color: const Color(0xFF21213F),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTeamColumn("HOME", detail.homeTeam),
                        ],
                      )),
                      SizedBox(
                        width: 27 * S.X_RATIO,
                      ),
                      Column(
                        children: [
                          SizedBox(height: 28 * S.Y_RATIO),
                          Text(
                            "${detail.hometeamScore} : ${detail.awayteamScore}",
                            style: TextStyle(
                              color: const Color(0xFFFF7400),
                              fontSize: 40.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Wanted sans',
                            ),
                          ),
                          SizedBox(height: 12 * S.Y_RATIO),
                          Text(
                            "${detail.matchDate}\n${detail.location}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFC1C1C1),
                              fontSize: 12.0 * S.Y_RATIO,
                              fontFamily: 'Wanted sans',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 27 * S.X_RATIO,
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTeamColumn("AWAY", detail.awayTeam),
                        ],
                      )),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30 * S.Y_RATIO),
                      Text(
                        "GOAL",
                        style: TextStyle(
                          color: const Color(0xFFFF7400),
                          fontSize: 12.0 * S.Y_RATIO,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Wanted sans',
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: _buildScorerList(homeScorers, maxGoals,
                                  CrossAxisAlignment.end),
                            ),
                          ),
                          SizedBox(width: 10 * S.X_RATIO),
                          Column(children: [
                            SizedBox(height: 8.0 * S.Y_RATIO),
                            Container(
                              width: 1,
                              height: (maxGoals * 20).toDouble(),
                              color: Colors.white,
                            ),
                          ]),
                          SizedBox(width: 10 * S.X_RATIO),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildScorerList(awayScorers, maxGoals,
                                  CrossAxisAlignment.start),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamColumn(String title, String teamName) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFFC9C9C9),
            fontSize: 14.0 * S.Y_RATIO,
            fontWeight: FontWeight.w500,
            fontFamily: 'Wanted sans',
          ),
        ),
        SizedBox(height: 6 * S.Y_RATIO),
        Container(
          height: 63 * S.Y_RATIO,
          width: 63 * S.Y_RATIO,
          decoration: const BoxDecoration(
            color: Color(0xFFD9D9D9),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 11 * S.Y_RATIO),
        Text(
          teamName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0 * S.Y_RATIO,
            fontWeight: FontWeight.w700,
            fontFamily: 'Wanted sans',
          ),
        ),
      ],
    );
  }

  List<Widget> _buildScorerList(
      List<Scorer> scorers, int max, CrossAxisAlignment align) {
    List<Widget> goalWidgets = [];
    for (int i = 0; i < max; i++) {
      if (i < scorers.length) {
        final s = scorers[i];
        goalWidgets.add(
          Padding(
            padding: EdgeInsets.only(top: 4.0 * S.Y_RATIO),
            child: Text(
              "${s.time}’  ${s.player}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0 * S.Y_RATIO,
                fontWeight: FontWeight.w500,
                fontFamily: 'Wanted sans',
              ),
            ),
          ),
        );
      } else {
        goalWidgets.add(const SizedBox(height: 20));
      }
    }
    return goalWidgets;
  }
}

class FormationWidget extends StatelessWidget {
  final MatchDetail detail;
  const FormationWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final formationImage = detail.formation;
    return Container(
      padding: EdgeInsets.only(top: 45 * S.Y_RATIO),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 300 * S.X_RATIO,
              child: Text(
                "포메이션",
                style: TextStyle(
                    fontSize: 14 * S.Y_RATIO,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Wanted sans',
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 10 * S.Y_RATIO),
            Container(

              padding: EdgeInsets.only(

                  top: 20* S.Y_RATIO,

                  left: 12* S.X_RATIO,

                  right: 12* S.X_RATIO,

                  bottom: 20* S.Y_RATIO),

              width: 300* S.X_RATIO,

              height: 550* S.Y_RATIO,

              decoration: BoxDecoration(

                color: const Color(0xFF21213F),

                borderRadius: BorderRadius.circular(15),

              ),

              child: formationImage.isNotEmpty

                  ? Image.network(

                formationImage,

                fit: BoxFit.contain,

                errorBuilder: (context, error, stackTrace) =>

                    FittedBox(child: Image.asset('assets/ban/formation.png')), // 기본 이미지

              )

                  : FittedBox(child: Image.asset('assets/ban/formation.png')), // 기본 이미지

            ),
          ],
        ),
      ),
    );
  }
}

class PersonalWidget extends ConsumerStatefulWidget {
  final MatchDetail detail;
  final String userToken;
  final int userId;
  final int teamId;
  final int gameNum;

  const PersonalWidget({
    super.key,
    required this.detail,
    required this.userToken,
    required this.userId,
    required this.teamId,
    required this.gameNum,
  });

  @override
  ConsumerState<PersonalWidget> createState() => _PersonalWidgetState();
}

class _PersonalWidgetState extends ConsumerState<PersonalWidget> {
  late List<String> fixedFeatures;
  late Map<String, double> featureValues;
  late String selectedFeature;
  late final MypageService mypageService;

  @override
  void initState() {
    super.initState();
    selectedFeature = widget.detail.selectedStat;
    // ✅ 포지션에 따라 고정 피처 설정
    mypageService = MypageService(authToken: widget.userToken);
    fixedFeatures = getFixedFeatures(widget.detail.position!.toUpperCase());
    // ✅ profile.stats에서 실제 데이터 가져오기
    featureValues = {
      "HED": widget.detail.hed.toDouble(),
      "FST": widget.detail.fst.toDouble(),
      "ACT": widget.detail.act.toDouble(),
      "OFF": widget.detail.off.toDouble(),
      "COP": widget.detail.cop.toDouble(),
      "PAC": widget.detail.pac.toDouble(),
      "CRO": widget.detail.cro.toDouble(),
      "TEC": widget.detail.tec.toDouble(),
      "PAS": widget.detail.pas.toDouble(),
      "DEC": widget.detail.dec.toDouble(),
      "BLD": widget.detail.bld.toDouble(),
      "DRV": widget.detail.drv.toDouble(),
      "TAC": widget.detail.tac.toDouble(),
      "SHO": widget.detail.sho.toDouble(),
      "DRI": widget.detail.dri.toDouble(),
      "SPD": widget.detail.spd.toDouble(),
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

  @override
  void didUpdateWidget(covariant PersonalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 부모 MatchDetail.selectedStat 이 바뀌면 로컬 selectedFeature 도 갱신
    if (oldWidget.detail.selectedStat != widget.detail.selectedStat) {
      setState(() {
        selectedFeature = widget.detail.selectedStat;
      });
    }
  }

  Future<void> _updateSelectedStat(String feature) async {
    try {
      await mypageService.updateSelectedStat(widget.userId, feature);
      // 서버 반영 후 캐시 무효화 → 즉시 다시 fetch
      ref.invalidate(matchDetailProvider(
        Tuple4(
          widget.userToken,
          widget.userId,
          widget.teamId,
          widget.gameNum,
        ),
      ));
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

  String formatStat(String feature) {
    final val = featureValues[feature] ?? 0.0;
    return val == -1 ? '-' : val.toStringAsFixed(0);
  }

  Color _getBackgroundColor(String result) {
    switch (result) {
      case "FW":
        return const Color(0xffff381e);
      case "MF":
        return const Color(0xff00d68f);
      case "DF":
        return const Color(0xff3028ff);
      case "GK":
        return const Color(0xffffea00);
      default:
        return const Color(0xffbcbcbc); // 기본 색상
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> displayedFeatures = [selectedFeature, ...fixedFeatures];
    List<double> displayedValues = displayedFeatures
        .map((feature) => featureValues[feature]! / 100)
        .toList();

    return Container(
      padding: EdgeInsets.only(top: 45 * S.Y_RATIO),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 300 * S.X_RATIO,
              child: Text(
                "개인 스탯",
                style: TextStyle(
                    fontSize: 14 * S.Y_RATIO,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Wanted sans',
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 10 * S.Y_RATIO),
            Container(
                padding: EdgeInsets.only(
                    top: 25 * S.Y_RATIO,
                    left: 12 * S.X_RATIO,
                    right: 12 * S.X_RATIO,
                    bottom: 20 * S.Y_RATIO),
                width: 300 * S.X_RATIO,
                decoration: BoxDecoration(
                  color: const Color(0xFF21213F),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "평점",
                                    style: TextStyle(
                                      color: const Color(0XFFC9C9C9),
                                      fontSize: 14 * S.Y_RATIO,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6 * S.Y_RATIO,
                                  ),
                                  Text(
                                    widget.detail.grade,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24 * S.Y_RATIO,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "포지션",
                                    style: TextStyle(
                                      color: const Color(0XFFC9C9C9),
                                      fontSize: 14 * S.Y_RATIO,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6 * S.Y_RATIO,
                                  ),
                                  Container(
                                    height: S.Y_RATIO * 36,
                                    width: S.X_RATIO * 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: _getBackgroundColor(
                                          widget.detail.position ?? '-'),
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
                                      child: Text(widget.detail.position ?? '-',
                                          style: TextStyle(
                                              fontSize: S.Y_RATIO * 24,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans',
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 25 * S.Y_RATIO,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "출전시간",
                                    style: TextStyle(
                                      color: const Color(0XFFC9C9C9),
                                      fontSize: 14 * S.Y_RATIO,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 22 * S.Y_RATIO,
                                  ),
                                  Text(
                                    widget.detail.playTime == '-'
                                        ? '-'
                                        : "${widget.detail.playTime}’",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24 * S.Y_RATIO,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "득점",
                                    style: TextStyle(
                                      color: const Color(0XFFC9C9C9),
                                      fontSize: 14 * S.Y_RATIO,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 22 * S.Y_RATIO,
                                  ),
                                  Text(
                                    widget.detail.score,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24 * S.Y_RATIO,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "도움",
                                    style: TextStyle(
                                      color: const Color(0XFFC9C9C9),
                                      fontSize: 14 * S.Y_RATIO,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 22 * S.Y_RATIO,
                                  ),
                                  Text(
                                    widget.detail.assist,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24 * S.Y_RATIO,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 45 * S.Y_RATIO,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SPECIAL',
                            style: TextStyle(
                              fontSize: 12 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans',
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _toggleDropdown, // 드롭다운을 열고 닫는 동작
                                  child: Text(
                                    selectedFeature,
                                    style: TextStyle(
                                      fontSize: 14 * S.Y_RATIO,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Wanted sans',
                                    ),
                                  ),
                                ),
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
                            formatStat(selectedFeature),
                            style: TextStyle(
                              color: const Color(0xFFFF7400),
                              fontSize: 18.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans',
                            ),
                          ),
                        ],
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
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // 클릭 이벤트 처리
                                      },
                                      child: Column(children: [
                                        //고정4번째 항목
                                        Text(
                                          fixedFeatures[4],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                        Text(
                                          formatStat(fixedFeatures[4]),
                                          style: TextStyle(
                                            color: const Color(0xFFFF7400),
                                            fontSize: 18.0 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                      ]),
                                    ),
                                    SizedBox(height: 60 * S.Y_RATIO),
                                    GestureDetector(
                                      onTap: () {
// 클릭 이벤트 처리
                                      },
                                      child: Column(children: [
                                        //고정3번째 항목
                                        Text(
                                          fixedFeatures[3],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                        Text(
                                          formatStat(fixedFeatures[3]),
                                          style: TextStyle(
                                            color: const Color(0xFFFF7400),
                                            fontSize: 18.0 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                      ]),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 206 * S.Y_RATIO,
                            child: RadarChart(
                              length: 6,
                              radius: 100 * S.Y_RATIO, //y로 할지 x로 할지
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
                          Expanded(
                            flex: 1, // 비율 조정 가능
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // 클릭 이벤트 처리
                                      },
                                      child: Column(children: [
                                        //고정4번째 항목
                                        Text(
                                          fixedFeatures[0],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                        Text(
                                          formatStat(fixedFeatures[0]),
                                          style: TextStyle(
                                            color: const Color(0xFFFF7400),
                                            fontSize: 18.0 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                      ]),
                                    ),
                                    SizedBox(height: 60 * S.Y_RATIO),
                                    GestureDetector(
                                      onTap: () {
// 클릭 이벤트 처리
                                      },
                                      child: Column(children: [
                                        //고정3번째 항목
                                        Text(
                                          fixedFeatures[1],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                        Text(
                                          formatStat(fixedFeatures[1]),
                                          style: TextStyle(
                                            color: const Color(0xFFFF7400),
                                            fontSize: 18.0 * S.Y_RATIO,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Wanted sans',
                                          ),
                                        ),
                                      ]),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // 클릭 이벤트 처리
                        },
                        child: Column(
                          children: [
                            Text(
                              fixedFeatures[2],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0 * S.Y_RATIO,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Wanted sans',
                              ),
                            ),
                            Text(
                              formatStat(fixedFeatures[2]),
                              style: TextStyle(
                                color: const Color(0xFFFF7400),
                                fontSize: 18.0 * S.Y_RATIO,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Wanted sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30 * S.Y_RATIO,
                      )
                    ],
                  ),
                  if (_isDropdownOpen)
                    Positioned(
                      top: 252 * S.Y_RATIO, // 원하는 위치로 조정
                      left: 110*S.X_RATIO, // 화면 중앙에 배치
                      child: Container(
                        width: 50 * S.X_RATIO,
                        padding: EdgeInsets.only(
                            top: 4.0 * S.Y_RATIO,
                            left: 4.0 * S.X_RATIO,
                            right: 4.0 * S.X_RATIO,
                            bottom: 4 * S.Y_RATIO),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF21213F),
                          border:
                              Border.all(color: const Color(0xFFFF7E1D), width: 1.8),
                        ),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min, // 항목 수에 따라 높이가 조정되도록 설정
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
                                padding: EdgeInsets.symmetric(
                                    vertical: 3.0 * S.Y_RATIO),
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14 * S.Y_RATIO,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Wanted sans',
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ])),
            SizedBox(height: 40 * S.Y_RATIO),
          ],
        ),
      ),
    );
  }
}
