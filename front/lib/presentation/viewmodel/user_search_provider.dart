import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
// ======================= 상태 관리 =======================

final userSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final userSearchResultProvider =
FutureProvider.autoDispose.family<List<UserSummary>, String>((ref, nickname) async {
  final token = ref.read(tokenProvider); // 토큰 제공자
  final uri = Uri.parse('http://localhost:8080/api/search/users');

  final response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'nickname': nickname}),
  );

  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);
    final List data = jsonDecode(body);
    return data.map((e) => UserSummary.fromJson(e)).toList();
  } else {
    throw Exception('검색 실패');
  }
});

// ======================= 모델 =======================

class UserSummary {
  final int userId;
  final String nickName;
  UserSummary({required this.userId, required this.nickName});

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      userId: json['userId'],
      nickName: json['nickName'],
    );
  }
}

