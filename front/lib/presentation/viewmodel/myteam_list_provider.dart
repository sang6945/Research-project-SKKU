// myTeamListProvider.dart
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// API 응답을 그대로 매핑할 DTO
class TeamListResult {
  final int statusCode;
  final String responseMessage;
  final List<Team> data;                  // ← 실제 팀 목록
  final bool hasUnreadNotification;       // ← 새로 추가된 플래그

  TeamListResult({
    required this.statusCode,
    required this.responseMessage,
    required this.data,
    required this.hasUnreadNotification,
  });

  factory TeamListResult.fromJson(Map<String, dynamic> json) {
    return TeamListResult(
      statusCode: json['statusCode'] as int,
      responseMessage: json['responseMessage'] as String,
      data: (json['data'] as List)
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasUnreadNotification: json['hasUnreadNotification'] as bool? ?? false,
    );
  }
}

class Team {
  final int teamId;
  final String teamName;
  final String teamImg;
  final String sports;
  final String ovr;
  final String homeTown1;
  final String memberNum;
  final String draw;
  final String lose;
  final String win;

  Team({
    required this.teamId,
    required this.teamName,
    required this.teamImg,
    required this.sports,
    required this.ovr,
    required this.homeTown1,
    required this.memberNum,
    required this.draw,
    required this.lose,
    required this.win,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    final fullHomeTown = (json['homeTown1'] as String?) ?? '';
    // 띄어쓰기 전까지(첫 번째 단어)만 추출
    // final prefixHomeTown = fullHomeTown.split(' ').first;
    return Team(
      teamId: json['teamId'],
      teamName: json['teamName'],
      teamImg: json['teamImg'] ?? '',
      sports: json['sports'],
      ovr: json['ovr'],
      homeTown1: json['homeTown1'],
      memberNum: json['memberNum'],
      draw: json['draw'],
      lose: json['lose'],
      win: json['win'],
    );
  }
}

final myTeamListProvider = FutureProvider.autoDispose<TeamListResult>((ref) async {
  final token = ref.read(tokenProvider);

  final response = await http.get(
    Uri.parse('http://localhost:8080/api/team/MyTeamList'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return TeamListResult.fromJson(body);
  } else {
    throw Exception('팀 리스트 로드 실패: ${response.body}');
  }
});