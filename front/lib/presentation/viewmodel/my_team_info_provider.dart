import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/services/change_team_service.dart';

class MyTeamInfo {
  final String? currentTeam;
  final String? teamImg;
  final String? win;
  final String? draw;
  final String? lose;
  final String fw;
  final String mf;
  final String df;

  MyTeamInfo({
    this.currentTeam,
    this.teamImg,
    required this.win,
    required this.draw,
    required this.lose,
    required this.fw,
    required this.mf,
    required this.df,
  });

  factory MyTeamInfo.fromJson(Map<String, dynamic> json) {
    return MyTeamInfo(
      currentTeam: json['currentTeam']?? '소속 없음',
      teamImg: json['teamImg'],
      fw: json['fw']?? '0',
      mf: json['mf']?? '0',
      df: json['df']?? '0',
      win: json['win']?? '0',
      draw: json['draw']?? '0',
      lose: json['lose']?? '0',
    );
  }
}

class MyTeamInfoNotifier extends StateNotifier<MyTeamInfo?> {
  MyTeamInfoNotifier() : super(null);

  Future<void> loadInitialTeamInfo({
    required int userId,
    required String token,
  }) async {
    final teamId = await getCurrentTeamId(userId: userId, token: token);
    if (teamId != null) {
      await fetchTeamInfo(userId: userId, teamId: teamId, token: token);
    } else {
      if (kDebugMode) {
        print('현재 팀 없음');
      }
    }
  }

  Future<void> fetchTeamInfo({
    required int userId,
    required int teamId,
    required String token,
  }) async {
    final info = await changeTeam(userId: userId, teamId: teamId, token: token);
    state = info;
  }
}

final myTeamInfoProvider = StateNotifierProvider<MyTeamInfoNotifier, MyTeamInfo?>(
      (ref) => MyTeamInfoNotifier(),
);
