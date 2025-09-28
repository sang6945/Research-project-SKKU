// lib/presentation/viewmodel/teamlist_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fineplay/presentation/viewmodel/token_provider.dart';

final hometeamListProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, userId) async {
  final token = ref.read(tokenProvider);

  final response = await http.post(
    Uri.parse('http://localhost:8080/api/home/TeamList'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'userId': userId}),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final List<dynamic> rawList = body['myTeamList'];

    // null 필터링
    final filteredList = rawList
        .where((team) => team['teamName'] != null && team['teamId'] != null)
        .map<Map<String, dynamic>>((team) => {
      'teamName': team['teamName']!,
      'teamId': team['teamId']!,
    })
        .toList();

    return filteredList;
  } else {
    throw Exception('팀 리스트 불러오기 실패: ${response.statusCode}');
  }
});
