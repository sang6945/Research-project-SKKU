// lib/presentation/viewmodel/team_memberlist_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 1) JSON ↔ 객체 매핑을 위한 모델 클래스
class TeamMember {
  final int userId;
  final bool leader;
  final String nickName;
  final String ovr;

  TeamMember({
    required this.userId,
    required this.leader,
    required this.nickName,
    required this.ovr,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
    userId: json['userId'] as int,
    leader: json['leader'] as bool,
    nickName: json['nickName'] as String,
    ovr: json['ovr'] as String,
  );
}

/// 2) teamId별 팀원 목록을 불러오는 FutureProvider.family
final teamMemberListProvider =
FutureProvider.autoDispose.family<List<TeamMember>, int>((ref, teamId) async {
  final token = ref.read(tokenProvider);
  final resp = await http.post(
    Uri.parse('http://localhost:8080/api/team/TeamMemberList'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'teamId': teamId}),
  );

  if (resp.statusCode != 200) {
    throw Exception('팀원 목록을 불러오지 못했습니다 (${resp.statusCode})');
  }

  final body = jsonDecode(resp.body) as Map<String, dynamic>;
  final data = body['data'] as List<dynamic>;
  return data.map((e) => TeamMember.fromJson(e as Map<String, dynamic>)).toList();
});
