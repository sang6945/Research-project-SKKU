
// ignore_for_file: unused_result, deprecated_member_use, library_private_types_in_public_api, non_constant_identifier_names

import 'package:fineplay/presentation/viewmodel/my_team_info_provider.dart';
import 'package:fineplay/presentation/viewmodel/myteam_list_provider.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:radar_chart/radar_chart.dart' as radar;
// NaviBar 참조
import 'package:fineplay/services/team_info_service.dart'; // teamInfoProvider
import 'package:tuple/tuple.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as bar;

class MyTeam_view extends ConsumerStatefulWidget {
  final int teamId;

  const MyTeam_view({
    super.key,
    required this.teamId,
  });

  @override
  _MyTeam_viewState createState() => _MyTeam_viewState();
}

class _MyTeam_viewState extends ConsumerState<MyTeam_view> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = ref.read(tokenProvider);
      final userId = ref.read(userIdProvider)!;
      ref.invalidate(teamInfoProvider(Tuple3(token, userId, widget.teamId)));
      ref.read(teamInfoProvider(Tuple3(token, userId, widget.teamId)));
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    final userToken = ref.watch(tokenProvider);
    final userId = ref.watch(userIdProvider);
    final teamInfoAsync =
    ref.watch(teamInfoProvider(Tuple3(userToken, userId!, widget.teamId)));

    return teamInfoAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          body: Center(child: Text('팀 정보 로드 실패: $err')),
        ),
        data: (team) => Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(70 * S.Y_RATIO),
            child: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                // ✅ title 중앙 정렬
                titleSpacing: 0,
                // ✅ 여백 없애기
                backgroundColor: const Color(0xFF030319),
                leading: Padding(
                  padding: EdgeInsets.only(
                      top: 25.0 * S.Y_RATIO, left: 10.0 * S.X_RATIO),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 20.0 * S.Y_RATIO,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.refresh(myTeamListProvider);
                      ref.refresh(myTeamInfoProvider);
                    },
                  ),
                ),
                title: Padding(
                  padding: EdgeInsets.only(top: 25.0 * S.Y_RATIO),
                  child: Text(
                    team.teamName, // 제목 텍스트
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0 * S.Y_RATIO,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Wanted sans'),
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(top: 25 * S.Y_RATIO),
                    child: IconButton(
                      icon: Icon(
                        Icons.group_outlined,
                        size: 23 * S.Y_RATIO,
                      ),
                      onPressed: () {
                        context.pushNamed('teammemberlist',
                        pathParameters: {'teamId': widget.teamId.toString()}
                        );

                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 25 * S.Y_RATIO, right: 30 * S.X_RATIO),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings,
                        size: 23 * S.Y_RATIO,
                      ),
                      onPressed: () {
                        context.pushNamed("teamsetting",
                            pathParameters:{"teamId": widget.teamId.toString()}
                        );
                      },
                    ),
                  ),
                ]),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                TeamInfoWidget(
                  team: team,
                ),
                Outline_StatWidget(
                  team: team,
                ),
                RecentMatchWidget(
                    team: team,
                    matchResults: team.matchResultList,
                    teamId: widget.teamId,
                    userToken: userToken,
                    userId: userId),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF030319),
        ));
  }
}

class TeamInfoWidget extends ConsumerWidget {
  final TeamInfo team;

  const TeamInfoWidget({super.key, required this.team});

  // void _onTagClicked(String tag) {
  //   // 각 태그 클릭 시 수행할 동작을 정의하세요.
  //   if (kDebugMode) {
  //     print('$tag 태그 클릭됨');
  //   }
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 33 * S.Y_RATIO),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "팀 정보",
                    style: TextStyle(
                        fontSize: 14 * S.Y_RATIO, fontFamily: 'Wanted sans'),
                  ),
                ),
                SizedBox(height: S.Y_RATIO * 10),
                Container(
                  height: S.Y_RATIO * 120,
                  width: S.X_RATIO * 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF21213F),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20 * S.X_RATIO,
                        top: 30 * S.Y_RATIO,
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
                                SizedBox(height: 10 * S.Y_RATIO),
                                Text(
                                  team.teamName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12 * S.Y_RATIO,
                                    fontFamily: 'Wanted sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 108 * S.X_RATIO,
                          top: 20 * S.Y_RATIO,
                        ),
                        child: SizedBox(
                          width: S.X_RATIO * 53,
                          child: Column(
                            children: [
                              Text(
                                'OVR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0 * S.Y_RATIO,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Wanted sans'),
                              ),
                              SizedBox(height: S.Y_RATIO * 8),
                              Container(
                                height: S.Y_RATIO * 32,
                                width: S.X_RATIO * 50,
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
                                  child: Text(team.ovr,
                                      style: TextStyle(
                                          fontSize: S.Y_RATIO * 16,
                                          fontWeight: FontWeight.w600,
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
                          left: 170 * S.X_RATIO,
                          top: 20 * S.Y_RATIO,
                        ),
                        child: SizedBox(
                          width: S.X_RATIO * 103,
                          child: Column(
                            children: [
                              Text(
                                '최근 전적',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0 * S.Y_RATIO,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Wanted sans'),
                              ),
                              SizedBox(height: S.Y_RATIO * 8),
                              Container(
                                height: S.Y_RATIO * 32,
                                width: S.X_RATIO * 100,
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
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown, // 자식 Text가 넘치면 축소
                                    alignment: Alignment.center,
                                    child: Text(
                                        "${team.recentWin15}W / ${team.recentDraw15}D / ${team.recentLose15}L",
                                        style: TextStyle(
                                            fontSize: S.Y_RATIO * 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Wanted sans',
                                            color: const Color(0xFF21213F))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 111 * S.X_RATIO,
                          top: 85 * S.Y_RATIO,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '#${team.homeTown}'),
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
                      )
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

class ChartData {
  final String range;
  final int blue;
  final int green;
  final int red;

  ChartData(this.range, this.blue, this.green, this.red);
}

class Outline_StatWidget extends StatefulWidget {
  final TeamInfo team;

  const Outline_StatWidget({super.key, required this.team});

  @override
  _Outline_StatWidgetState createState() => _Outline_StatWidgetState();
}

class _Outline_StatWidgetState extends State<Outline_StatWidget> {
  final List<String> Position = ["FW", "MF", "DF"];
  final List<String> CommonFeatures = ["SPD", "PAS", "PAC"]; //공통지표
  late final List<String> fixedFeatures = [
    Position[0],
    Position[1],

    CommonFeatures[0],
    CommonFeatures[1],
    CommonFeatures[2],
    Position[2],
  ];

  Map<String, double> get featureValues => {
    "FW": double.parse(widget.team.fw),
    "MF": double.parse(widget.team.mf),
    "DF": double.parse(widget.team.df),
    "SPD": double.parse(widget.team.spd),
    "PAS": double.parse(widget.team.pas),
    "PAC": double.parse(widget.team.pac), //개인
  };

  /*final List<ChartData> chartData = List.generate(
    10,
    (i) {
      final label = '~${(i + 1) * 10}';
      // 예시 값들, 실제 ovrBins 같은 리스트에서 꺼내 쓰셔도 좋습니다.
      final blue = [5, 7, 28, 11, 14, 15, 17, 18, 19, 20][i];
      final green = [3, 14, 16, 7, 8, 9, 11, 12, 13, 14][i];
      final red = [2, 3, 14, 5, 6, 6, 7, 8, 9, 10][i];
      return ChartData(label, blue, green, red);
    },
  );*/ //막대그래프 예시

  @override
  Widget build(BuildContext context) {
    List<String> displayedFeatures = fixedFeatures;
    List<double> displayedValues = displayedFeatures
        .map((feature) => featureValues[feature]! / 100)
        .toList();

    final chartData = widget.team.statDistribution
        .map((d) => ChartData(d.range, d.dfCount, d.mfCount, d.fwCount))
        .toList();

    // 1) 각 스택 총합 계산
    final double maxTotal = chartData
        .map((d) => (d.blue + d.green + d.red).toDouble())
        .reduce((a, b) => a > b ? a : b);

    // 2) 10 단위로 올림 (ceil returns int, *10.0 → double)
    final double yAxisMax = (maxTotal / 5).ceil() * 5.0;

    return Stack(children: [
      Container(
          padding: EdgeInsets.only(top: 12 * S.Y_RATIO),
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  //바탕
                  height: S.Y_RATIO * 800,
                  width: S.X_RATIO * 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF21213F),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(children: [
                    //클럽개요
                    Center(
                        child:
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          SizedBox(height: S.Y_RATIO * 20),
                          SizedBox(
                            width: S.X_RATIO * 260,
                            child: Text(
                              "클럽 개요",
                              style: TextStyle(
                                  fontSize: 16 * S.Y_RATIO,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Wanted sans'),
                            ),
                          ),

                          Container(
                            height: S.Y_RATIO * 2.0,
                            width: S.X_RATIO * 260,
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0 * S.Y_RATIO), // 간격 조절
                          ),
                          SizedBox(height: S.Y_RATIO * 10),
                          SizedBox(
                            width: S.X_RATIO * 240,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "팀 내 OVR 분포",
                                  style: TextStyle(
                                    fontSize: 14 * S.Y_RATIO,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Wanted sans',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6 * S.X_RATIO),
                                Tooltip(
                                  verticalOffset: 18.0 * S.Y_RATIO,

                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0 * S.X_RATIO,
                                      vertical: 8.0 * S.Y_RATIO),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF616193),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  // 3) richMessage + WidgetSpan 으로 너비 제약 주기
                                  richMessage: WidgetSpan(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: 120.0 * S.X_RATIO, // 원하는 너비로만 제약
                                      ),
                                      child: Text(
                                        '팀 내 OVR 분포는 x축에 OVR 구간, y축에 해당 구간의 선수 수를 표시합니다.'
                                            '\n파란색은 수비수, 초록색은 미드필더, 빨간색은 공격수를 나타냅니다.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0 * S.Y_RATIO,
                                          fontFamily: 'Wanted sans',
                                        ),
                                        softWrap: true, // 컨테이너 너비 내에서 줄바꿈 허용
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 16 * S.Y_RATIO,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: S.Y_RATIO * 30),
                          //막대그래프 자리
                          SizedBox(
                            height: S.Y_RATIO * 200,
                            width: S.X_RATIO * 260,
                            child: bar.SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              primaryXAxis: const bar.CategoryAxis(
                                // 1) 레이블을 막대 사이에
                                labelPlacement: bar.LabelPlacement.betweenTicks,
                                // 레이블 간격: 데이터 수만큼 모두 표시
                                interval: 1,
                                axisLine: bar.AxisLine(color: Colors.white),
                                // 눈금 선(세로 줄) 없애기
                                majorGridLines: bar.MajorGridLines(width: 0),
                                // (선택) 눈금 표시선도 없애려면:
                                majorTickLines: bar.MajorTickLines(size: 0),
                                labelStyle: TextStyle(
                                  color: Colors.white, // 글자 크기
                                  fontWeight: FontWeight.w400, // 굵기
                                  fontFamily: 'Wanted sans',
                                ),
                              ),
                              primaryYAxis: bar.NumericAxis(
                                minimum: 0,
                                maximum: yAxisMax,
                                // 계산된 동적 최대값
                                interval: 5,
                                axisLine: const bar.AxisLine(color: Colors.white),
                                majorGridLines: const bar.MajorGridLines(width: 0),
                                majorTickLines: const bar.MajorTickLines(size: 0),
                                labelStyle: const TextStyle(
                                  color: Colors.white, // 글자 크기
                                  fontWeight: FontWeight.w400, // 굵기
                                  fontFamily: 'Wanted sans',
                                ),
                              ),
                              series: <bar.CartesianSeries>[
                                bar.StackedColumnSeries<ChartData, String>(
                                  dataSource: chartData,
                                  xValueMapper: (ChartData data, _) => data.range,
                                  yValueMapper: (ChartData data, _) => data.blue,
                                  color: const Color(0xff273dff),
                                ),
                                bar.StackedColumnSeries<ChartData, String>(
                                  dataSource: chartData,
                                  xValueMapper: (ChartData data, _) => data.range,
                                  yValueMapper: (ChartData data, _) => data.green,
                                  color: const Color(0xff37b24a),
                                ),
                                bar.StackedColumnSeries<ChartData, String>(
                                  dataSource: chartData,
                                  xValueMapper: (ChartData data, _) => data.range,
                                  yValueMapper: (ChartData data, _) => data.red,
                                  color: const Color(0xffc93f3f),
                                ),
                              ],
                            ),
                          ),
                        ])),

                    SizedBox(height: 35 * S.Y_RATIO),

                    //스탯분포

                    Column(
                      children: [
                        SizedBox(height: 13.0 * S.Y_RATIO),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(children: [
                              SizedBox(
                                width: S.X_RATIO * 240,
                                child: Text(
                                  "스탯 분포",
                                  style: TextStyle(
                                      fontSize: 14 * S.Y_RATIO,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Wanted sans'),
                                ),
                              ),

                              SizedBox(height: 25 * S.Y_RATIO),
                              Text.rich(
                                textAlign: TextAlign.center,
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: widget.team.teamName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0 * S.Y_RATIO,
                                          // 글자 크기를 더 크게 설정
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Wanted sans'),
                                    ),
                                    TextSpan(
                                      text: ' 팀의 OVR은 ',
                                      style: TextStyle(
                                          color: const Color(0xFFFFE3CE),
                                          fontSize: 12.0 * S.Y_RATIO,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Wanted sans'),
                                    ),
                                    TextSpan(
                                      text: '상위 ${widget.team.ovrPercent}%',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0 * S.Y_RATIO,
                                          // 글자 크기를 더 크게 설정
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Wanted sans' // 더 두껍게 설정
                                      ),
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
                              SizedBox(height: 25 * S.Y_RATIO),
                              //FW
                              Container(
                                height: S.Y_RATIO * 24,
                                width: S.X_RATIO * 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: const Color(0xffda3a25),
                                ),
                                child: Center(
                                  child: Text(fixedFeatures[0],
                                      style: TextStyle(
                                          fontSize: S.Y_RATIO * 12,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Wanted sans',
                                          color: Colors.white)),
                                ),
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
                                      Column(children: [
                                        //DF
                                        Container(
                                          height: S.Y_RATIO * 24,
                                          width: S.X_RATIO * 44,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                            color: const Color(0xff2d27d9),
                                          ),
                                          child: Center(
                                            child: Text(fixedFeatures[5],
                                                style: TextStyle(
                                                    fontSize: S.Y_RATIO * 12,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Wanted sans',
                                                    color: Colors.white)),
                                          ),
                                        ),
                                        Text(
                                          (featureValues[fixedFeatures[5]] ?? 0.0)
                                              .toStringAsFixed(0),
                                          style: TextStyle(
                                              color: const Color(0xFFFF7400),
                                              fontSize: 18.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                      ]),
                                      SizedBox(height: 60 * S.Y_RATIO),
                                      Column(children: [
                                        //공통3번째 항목
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 206 * S.Y_RATIO,
                              child: radar.RadarChart(
                                length: 6,
                                radius: 100 * S.Y_RATIO,
                                //y로 할지 x로 할지
                                initialAngle: (3.14 / 6) * 9,
                                backgroundColor: const Color(0xFF343456),
                                borderStroke: 2,
                                borderColor: const Color(0xFF41415A),
                                radars: [
                                  radar.RadarTile(
                                    values: const [0.75, 0.75, 0.75, 0.75, 0.75, 0.75],
                                    borderStroke: 2,
                                    borderColor: const Color(0xFF59597C),
                                    backgroundColor: const Color(0xFF515172),
                                  ),
                                  radar.RadarTile(
                                    values: const [0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
                                    borderStroke: 2,
                                    borderColor: const Color(0xFF67678A),
                                    backgroundColor: const Color(0xFF626282),
                                  ),
                                  radar.RadarTile(
                                    values: const [0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
                                    borderStroke: 2,
                                    borderColor: const Color(0xFF9E9ED1),
                                    backgroundColor: const Color(0xFF8787B3),
                                  ),
                                  radar.RadarTile(
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
                                      Column(children: [
                                        //MF
                                        Container(
                                          height: S.Y_RATIO * 24,
                                          width: S.X_RATIO * 44,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                            color: const Color(0xff00d68f),
                                          ),
                                          child: Center(
                                            child: Text(fixedFeatures[1],
                                                style: TextStyle(
                                                    fontSize: S.Y_RATIO * 12,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'Wanted sans',
                                                    color: Colors.white)),
                                          ),
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
                                      SizedBox(height: 60 * S.Y_RATIO),
                                      Column(children: [
                                        //공통1번째 항목
                                        Text(
                                          fixedFeatures[2],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                        Text(
                                          (featureValues[fixedFeatures[2]] ?? 0.0)
                                              .toStringAsFixed(0),
                                          style: TextStyle(
                                              color: const Color(0xFFFF7400),
                                              fontSize: 18.0 * S.Y_RATIO,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Wanted sans'),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          //공통2번째
                          children: [
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
                          ],
                        ),
                      ],
                    ),
                  ]),
                )
              ]))),
    ]);
  }
}

class RecentMatchWidget extends StatelessWidget {
  final List<MatchResult> matchResults;
  final TeamInfo team;
  final int teamId;
  final String userToken;
  final int userId;

  const RecentMatchWidget({
    super.key,
    required this.team,
    required this.matchResults,
    required this.teamId,
    required this.userToken,
    required this.userId,
  });

  void _onFeatureTap(BuildContext context, int matchId) {
    if (kDebugMode) {
      print('Match ID: $matchId 클릭됨');
    }
    context.pushNamed(
      'gameresult',
      pathParameters: {
        'token':  userToken,
        'userId': userId.toString(),
        'teamId': teamId.toString(),
        'gameNum': matchId.toString(),
      },
    );
  }

  Color _getBackgroundColor(String result) {
    switch (result) {
      case "Win":
        return const Color(0xff07b27f); // 초록색 (승리)
      case "Draw":
        return const Color(0xffbcbcbc); // 회색 (무승부)
      case "Lose":
        return const Color(0xfff63f3f); // 빨간색 (패배)
      default:
        return const Color(0xFF21213F); // 기본 색상
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 20.0 * S.Y_RATIO,
          left: 20.0 * S.X_RATIO,
          right: 20.0 * S.X_RATIO,
          bottom: 20.0 * S.Y_RATIO),
      margin: EdgeInsets.only(top: 10.0 * S.Y_RATIO),
      width: 300 * S.X_RATIO,
      height: 530 * S.Y_RATIO,
      decoration: BoxDecoration(
        color: const Color(0xFF21213F),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 최근 전적 및 승률
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "전체 전적",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0 * S.Y_RATIO,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Wanted sans'),
                  ),
                  SizedBox(height: 10.0 * S.Y_RATIO),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: team.totalWin, // 숫자
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans'),
                        ),
                        TextSpan(
                          text: "W  ", // 영어
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans'),
                        ),
                        TextSpan(
                          text: team.totalDraw, // 숫자
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans'),
                        ),
                        TextSpan(
                          text: "D  ", // 영어
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans'),
                        ),
                        TextSpan(
                          text: team.totalLose, // 숫자
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans'),
                        ),
                        TextSpan(
                          text: "L", // 영어
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        "승률",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0 * S.Y_RATIO,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Wanted sans'),
                      ),
                      SizedBox(width: 5 * S.X_RATIO)
                    ],
                  ),
                  SizedBox(height: 10.0 * S.Y_RATIO),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: team.winningRate, // 숫자
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Wanted sans'),
                        ),
                        TextSpan(
                          text: "%", // %
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
            ],
          ),
          SizedBox(height: 5.0 * S.Y_RATIO),

          Container(
            height: S.Y_RATIO * 2.0,
            width: S.X_RATIO * 260,
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10.0 * S.Y_RATIO), // 간격 조절
          ),

          SizedBox(height: 10.0 * S.Y_RATIO),
          // 경기 결과 타이틀
          Column(
            children: [
              // 경기 결과 (왼쪽 정렬)
              Align(
                alignment: Alignment.centerLeft, // 왼쪽 정렬
                child: Text(
                  "경기 결과",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0 * S.Y_RATIO,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Wanted sans'),
                ),
              ),
              // 더보기 (오른쪽 정렬)
              Padding(
                padding: EdgeInsets.only(right: 5.0 * S.X_RATIO), // 오른쪽 마진 추가
                child: Align(
                  alignment: Alignment.centerRight, // 오른쪽 정렬
                  child: TextButton(
                    onPressed: () {

                      context.pushNamed('allmatchview',
                          pathParameters: {'teamId':teamId.toString(), 'userId':userId.toString()},
                          queryParameters: {'userToken':userToken}, extra:team);

                    },
                    style: ButtonStyle(
                      padding:
                      MaterialStateProperty.all(EdgeInsets.zero), // 패딩 제거
                      minimumSize:
                      MaterialStateProperty.all(Size.zero), // 최소 크기 제거
                      tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
                    ),
                    child: Text(
                      "더보기",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0 * S.Y_RATIO,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Wanted sans'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5 * S.Y_RATIO),
          // 경기 결과 목록
          Column(
            children: matchResults.map((match) {
              return GestureDetector(
                onTap: () {
                  _onFeatureTap(context, int.parse(match.matchId));
                },
                child: MatchResultCard(
                  homeTeam: match.homeTeam,
                  score: '${match.homeScore} : ${match.awayScore}',
                  awayTeam: match.awayTeam,
                  backgroundColor: _getBackgroundColor(match.result),
                  date: match.date,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class MatchResultCard extends StatelessWidget {
  final String homeTeam;
  final String score;
  final String awayTeam;
  final Color backgroundColor;
  final String date;

  const MatchResultCard({super.key,
    required this.homeTeam,
    required this.score,
    required this.awayTeam,
    required this.backgroundColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260 * S.X_RATIO,
      height: 55 * S.Y_RATIO,
      margin: EdgeInsets.symmetric(vertical: 5.0 * S.Y_RATIO),
      padding: EdgeInsets.symmetric(
        vertical: 5.0 * S.Y_RATIO,
        horizontal: 40.0 * S.X_RATIO,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          // 왼쪽 HOME 영역
          Expanded(
            flex: 3,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "HOME",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.0 * S.Y_RATIO,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Wanted sans',
                    ),
                  ),
                  SizedBox(height: 2.0 * S.Y_RATIO),
                  Text(
                    homeTeam,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0 * S.Y_RATIO,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Wanted sans',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // 중앙 날짜·스코어 영역
          Expanded(
            flex: 2,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.0 * S.Y_RATIO,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Wanted sans',
                    ),
                  ),
                  SizedBox(height: 4.0 * S.Y_RATIO),
                  Text(
                    score,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0 * S.Y_RATIO,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Wanted sans',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 오른쪽 AWAY 영역
          Expanded(
            flex: 3,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "AWAY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.0 * S.Y_RATIO,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Wanted sans',
                    ),
                  ),
                  SizedBox(height: 2.0 * S.Y_RATIO),
                  Text(
                    awayTeam,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0 * S.Y_RATIO,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Wanted sans',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}