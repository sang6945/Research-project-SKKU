// team_search_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';

/// 간단한 팀 요약 모델
class TeamSummary {
  final String teamName;
  final int teamId;

  TeamSummary({required this.teamName, required this.teamId});

  factory TeamSummary.fromJson(Map<String, dynamic> json) {
    return TeamSummary(
      teamName: json['teamName'] as String,
      teamId: json['teamId'] as int,
    );
  }
}

/// 검색어에 따른 팀 리스트 프로바이더
/// 사용 예: ref.watch(teamSearchProvider(searchQuery))
final teamSearchProvider =
FutureProvider.family<List<TeamSummary>, String>((ref, query) async {
  // 토큰 읽어오기
  final token = ref.read(tokenProvider);

  // API 호출 URL
  final uri = Uri.parse(
    'http://localhost:8080/api/team/search?SearchContent=$query',
  );

  // GET 요청 시 헤더에 토큰 포함
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final String jsonString = utf8.decode(response.bodyBytes);
    final List jsonData = jsonDecode(jsonString)['data'];
    return jsonData.map((e) => TeamSummary.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load team list');
  }
});
