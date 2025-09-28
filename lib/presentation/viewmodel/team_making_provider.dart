import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeamMakingState {
  final String teamName;
  final String hometown; // 예: 시/도
  final String district; // 예: 군/구
  final String sport;
  final bool autoAccept;

  TeamMakingState({
    this.teamName = '',
    this.hometown = '',
    this.district = '',
    this.sport = '',
    this.autoAccept = false,
  });

  TeamMakingState copyWith({
    String? teamName,
    String? hometown,
    String? district,
    String? sport,
    bool? autoAccept,
  }) {
    return TeamMakingState(
      teamName: teamName ?? this.teamName,
      hometown: hometown ?? this.hometown,
      district: district ?? this.district,
      sport: sport ?? this.sport,
      autoAccept: autoAccept ?? this.autoAccept,
    );
  }
}

class TeamMakingNotifier extends StateNotifier<TeamMakingState> {
  TeamMakingNotifier() : super(TeamMakingState());

  void updateTeamName(String teamName) {
    state = state.copyWith(teamName: teamName);
  }

  void updateHometown(String hometown) {
    state = state.copyWith(hometown: hometown);
  }

  void updateDistrict(String district) {
    state = state.copyWith(district: district);
  }

  void updateSport(String sport) {
    state = state.copyWith(sport: sport);
  }

  void updateAutoAccept(bool autoAccept) {
    state = state.copyWith(autoAccept: autoAccept);
  }

  Future<void> createTeam(String token) async {
    final url = Uri.parse("http://localhost:8080/api/team/teamMake");
    final data = {
      "teamName": state.teamName,
      "homeTown1": state.hometown,
      "homeTown2": state.district,
      "sports": state.sport,
      "autoAccept": state.autoAccept,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // 팀 생성 성공 시 상태 초기화 등 후속 처리
      reset();
    } else {
      throw Exception("팀 생성 실패: ${response.statusCode} - ${response.body}");
    }
  }

  void reset() {
    state = TeamMakingState();
  }
}

final teamMakingProvider =
StateNotifierProvider<TeamMakingNotifier, TeamMakingState>(
        (ref) => TeamMakingNotifier());
