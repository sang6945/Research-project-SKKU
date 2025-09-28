// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';  // 또는 Navigator
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:fineplay/services/team_info_service.dart';
import 'package:fineplay/presentation/view/team_view/myteam_view.dart'; // MatchResultCard 재사용
import 'package:tuple/tuple.dart';

class AllMatchView extends ConsumerStatefulWidget {
  final TeamInfo team;
  final String userToken;
  final int teamId;
  final int userId;

  const AllMatchView({
    super.key,
    required this.team,
    required this.userToken,
    required this.teamId,
    required this.userId,
  });

  @override
  ConsumerState<AllMatchView> createState() => _AllMatchViewState();
}

class _AllMatchViewState extends ConsumerState<AllMatchView> {
  @override
  void initState() {
    super.initState();
    // BuildContext가 준비된 뒤에 실행
    Future.microtask(() {
      // 1) 캐시 무효화
      ref.invalidate(allMatchResultsProvider(
        Tuple2(widget.userToken, widget.teamId),
      ));
      // 2) 즉시 재요청
      ref.read(allMatchResultsProvider(
        Tuple2(widget.userToken, widget.teamId),
      ));
    });
  }

  Color _getBackgroundColor(String result) {
    switch (result) {
      case "Win":
        return const Color(0xff07b27f);
      case "Draw":
        return const Color(0xffbcbcbc);
      case "Lose":
        return const Color(0xfff63f3f);
      default:
        return const Color(0xFF21213F);
    }
  }

  void _onFeatureTap(BuildContext context, int matchId) {
    if (kDebugMode) {
      print('Match ID: $matchId 클릭됨');
    }
    context.pushNamed(
      'gameresult',
      pathParameters: {
        'token':  widget.userToken,
        'userId': widget.userId.toString(),
        'teamId': widget.teamId.toString(),
        'gameNum': matchId.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    final asyncMatches = ref.watch(
      allMatchResultsProvider(Tuple2(widget.userToken, widget.teamId)),
    );

    return asyncMatches.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF030319),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: const Color(0xFF030319),
        body: Center(
          child: Text('전체 경기 로드 실패: $err',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (matches) => Scaffold(
        backgroundColor: const Color(0xFF030319),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70 * S.Y_RATIO),
          child: AppBar(
            backgroundColor: const Color(0xFF030319),
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
                          fontWeight: FontWeight.w700,fontFamily: 'Wanted sans',
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
                          top: 25.0 * S.Y_RATIO, left: 10.0 * S.X_RATIO), // 왼쪽 여백
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
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20 * S.Y_RATIO),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 타이틀
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 35 * S.X_RATIO),
                child: Text(
                  "전체 경기 결과",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14 * S.Y_RATIO,
                    fontWeight: FontWeight.w700,fontFamily: 'Wanted sans',
                  ),
                ),
              ),

              SizedBox(height: 12 * S.Y_RATIO),

              // record + 승률 박스
              Center(
                child: Container(
                  width: 300 * S.X_RATIO,
                  padding: EdgeInsets.symmetric(
                    vertical: 25 * S.Y_RATIO,
                    horizontal: 25 * S.X_RATIO,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21213F),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(children:[Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 전적
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '전체 전적',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,fontFamily: 'Wanted sans',
                            ),
                          ),
                          SizedBox(height: 8 * S.Y_RATIO),
                          Row(
                            // 여기만 추가!
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Win count
                              Text(
                                widget.team.totalWin,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20 * S.Y_RATIO,
                                  fontWeight: FontWeight.bold,fontFamily: 'Wanted sans',
                                ),
                              ),
                              // W 라벨
                              Text(
                                'W',
                                style: TextStyle(
                                  color: const Color(0xff07b27f),
                                  fontSize: 13 * S.Y_RATIO,
                                  fontWeight: FontWeight.bold,fontFamily: 'Wanted sans',
                                ),
                              ),

                              SizedBox(width: 12 * S.X_RATIO),

                              // Draw count
                              Text(
                                widget.team.totalDraw,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20 * S.Y_RATIO,
                                  fontWeight: FontWeight.bold,fontFamily: 'Wanted sans',
                                ),
                              ),
                              // D 라벨
                              Text(
                                'D',
                                style: TextStyle(
                                  color: const Color(0xffbcbcbc),
                                  fontSize: 13 * S.Y_RATIO,
                                  fontWeight: FontWeight.bold,fontFamily: 'Wanted sans',
                                ),
                              ),

                              SizedBox(width: 12 * S.X_RATIO),

                              // Lose count
                              Text(
                                widget.team.totalLose,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20 * S.Y_RATIO,
                                  fontWeight: FontWeight.bold,fontFamily: 'Wanted sans',
                                ),
                              ),
                              // L 라벨
                              Text(
                                'L',
                                style: TextStyle(
                                  color: const Color(0xfff63f3f),
                                  fontSize: 13 * S.Y_RATIO,
                                  fontWeight: FontWeight.bold,fontFamily: 'Wanted sans',
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                      // 승률
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('승률  ', style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * S.Y_RATIO,
                            fontWeight: FontWeight.w700,fontFamily: 'Wanted sans',
                          ),),
                          SizedBox(height: 8 * S.Y_RATIO),
                          Text(
                            '${widget.team.winningRate}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20 * S.Y_RATIO,
                              fontWeight: FontWeight.bold,fontFamily: 'Wanted sans',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                    SizedBox(height: 12 * S.Y_RATIO),

                    // divider
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0 * S.X_RATIO),
                      child: const Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),


                    // 매치 리스트
                    ...matches.map((m) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(top:3*S.Y_RATIO),
                          child: FittedBox(
                            child: SizedBox(
                              width: 260 * S.X_RATIO,
                              child: GestureDetector(
                                onTap: () {
                                  _onFeatureTap(context, int.parse(m.matchId));
                                },
                                child: FittedBox(
                                  child: MatchResultCard(
                                    homeTeam: m.homeTeam,
                                    score: '${m.homeScore} : ${m.awayScore}',
                                    awayTeam: m.awayTeam,
                                    backgroundColor: _getBackgroundColor(m.result),
                                    date: m.date,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),]),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}