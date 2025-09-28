import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fineplay/presentation/viewmodel/my_team_info_provider.dart';

Future<MyTeamInfo> changeTeam({
  required int userId,
  required int teamId,
  required String token,
}) async {
  final uri = Uri.parse('http://localhost:8080/api/home/ChangeTeam');
  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'userId': userId, 'teamId': teamId}),
  );

  if (response.statusCode == 200) {
    return MyTeamInfo.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('팀 정보 변경 실패');
  }
}

/// ✅ 현재 선택된 팀(teamId) 가져오는 함수 추가
Future<int?> getCurrentTeamId({
  required int userId,
  required String token,
}) async {
  final uri = Uri.parse('http://localhost:8080/api/home/TeamCurrent');
  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'userId': userId}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['teamId'];
  } else {
    if (kDebugMode) {
      print('TeamCurrent API 실패: ${response.statusCode}');
    }
    return null;
  }
}
