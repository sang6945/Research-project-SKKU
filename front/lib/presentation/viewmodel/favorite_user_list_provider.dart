// lib/presentation/viewmodel/favorite_user_list_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';

/// 즐겨찾기 유저 모델
class FavoriteUser {
  final int userId;
  final String nickName;
  final String position;
  final int ovr;

  FavoriteUser({
    required this.userId,
    required this.nickName,
    required this.position,
    required this.ovr,
  });

  factory FavoriteUser.fromJson(Map<String, dynamic> json) {
    return FavoriteUser(
      userId: json['userId'] as int,
      nickName: json['nickName'] as String,
      position: json['position'] as String,
      ovr: json['ovr'] as int,
    );
  }
}

/// 즐겨찾기 유저 리스트를 가져오는 프로바이더
final favoriteUserListProvider =
FutureProvider.autoDispose<List<FavoriteUser>>((ref) async {
  final token  = ref.read(tokenProvider);
  final userId = ref.read(userIdProvider)!;
  final uri = Uri.parse(
    'http://localhost:8080/api/favorite/user/list?userId=$userId',
  );

  final resp = await http.get(uri, headers: {
    'Authorization': 'Bearer $token',
  });

  if (resp.statusCode == 200) {
    final body = jsonDecode(utf8.decode(resp.bodyBytes));
    final List data = body['favoriteUsers'] as List;
    return data.map((e) => FavoriteUser.fromJson(e)).toList();
  } else {
    throw Exception('즐겨찾기 목록 조회 실패: ${resp.body}');
  }
});
