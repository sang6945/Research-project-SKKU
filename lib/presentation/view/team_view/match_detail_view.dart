import 'package:flutter/material.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import '../../../services/team_info_service.dart';
import '../../viewmodel/token_provider.dart';

class Match_detail_view extends ConsumerWidget {
  final int teamId;
  final int matchId;
  final String userToken;

  const Match_detail_view({
    super.key,
    required this.userToken,
    required this.teamId,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);
    final token = ref.watch(tokenProvider);
    final statsAsync = ref.watch(matchStatsProvider(
      Tuple3(token, teamId, matchId),
    ));
    return statsAsync.when(
        loading: () => const Scaffold(
          backgroundColor: Color(0xFF030319),
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          backgroundColor: const Color(0xFF030319),
          body: Center(
            child: Text('매치 통계 로드 실패: $err',
                style: const TextStyle(color: Colors.white)),
          ),
        ),
        data: (stats) => Scaffold(
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
                _MatchStatWidget(stats: stats),
                SizedBox(
                  height: 40 * S.Y_RATIO,
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF030319),
        ));
  }
}

class _MatchStatWidget extends StatelessWidget{
  final MatchStats stats;

  const _MatchStatWidget({required this.stats});


  @override
  Widget build(BuildContext context) {
    // JSON 키 → 한글 라벨 매핑
    final mapping = {
      'score': '득점',
      'shooting': '슈팅',
      'onTarget': '유효슈팅',
      'possession': '점유율',
      'pass': '패스',
      'tackle': '태클',
      'foul': '파울',
      'card': '카드',
      'rating': '평점',
    };

    // 가독성을 위해 필요한 구조로 재조합
    final matchStats = {
      'homeTeam': stats.homeTeamName,
      'awayTeam': stats.awayTeamName,
      for (var key in mapping.keys)
        mapping[key]!: {
          'home': stats.home[key]!,
          'away': stats.away[key]!
        }
    };

    return Center(
      child: Container(
        padding: EdgeInsets.all(40 * S.Y_RATIO),
        width: 300 * S.X_RATIO,
        decoration: BoxDecoration(
          color: const Color(0xFF21213D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // 팀명 Row
            Row(
              children: [
                Expanded(
                  child: _teamColumn(
                    "HOME",
                    matchStats['homeTeam']! as String,
                    CrossAxisAlignment.center,  // ← 가운데 정렬
                  ),
                ),

                // 세로 분할선
                SizedBox(
                  height: 60 * S.Y_RATIO,
                  child: const VerticalDivider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),

                Expanded(
                  child: _teamColumn(
                    "AWAY",
                    matchStats['awayTeam']! as String,
                    CrossAxisAlignment.center,  // ← 가운데 정렬
                  ),
                ),
              ],
            ),
            SizedBox(height: 70 * S.Y_RATIO),
            // 통계 항목들
            ...matchStats.entries
                .where((e) => e.key != 'homeTeam' && e.key != 'awayTeam')
                .expand<Widget>((e) {
              final label = e.key;
              final statMap = e.value as Map<String, String>;
              final home = statMap['home']!;
              final away = statMap['away']!;
              // 기본 행
              final row = _buildStatRow(label, home, away);
              // '패스' 다음에만 추가 간격 삽입
              if (label == '패스') {
                return [
                  row,
                  SizedBox(height: 30 * S.Y_RATIO), // 원하는 만큼 조정
                ];
              }
              return [row];
            }),
          ],
        ),
      ),
    );
  }

  Widget _teamColumn(String title, String name, CrossAxisAlignment align) {
    return Expanded(
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(title,
              style: TextStyle(
                  color: const Color(0xFFC9C9C9),
                  fontSize: 16 * S.Y_RATIO,fontFamily: 'Wanted sans',
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 2 * S.Y_RATIO),
          Text(name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24 * S.Y_RATIO,fontFamily: 'Wanted sans',
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String homeValue, String awayValue) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * S.Y_RATIO),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(homeValue,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * S.Y_RATIO,fontFamily: 'Wanted sans',
                    fontWeight: FontWeight.w500)),
          ),
          SizedBox(width: 10 * S.X_RATIO),
          Expanded(
            flex: 6,
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * S.Y_RATIO,fontFamily: 'Wanted sans',
                    fontWeight: FontWeight.w700)),
          ),
          SizedBox(width: 10 * S.X_RATIO),
          Expanded(
            flex: 2,
            child: Text(awayValue,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * S.Y_RATIO,fontFamily: 'Wanted sans',
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
