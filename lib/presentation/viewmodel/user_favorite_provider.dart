// presentation/viewmodel/user_favorite_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';

/// favoriteUserId(조회 대상) → isFavorite 반환
final isUserFavoriteProvider = FutureProvider.family<bool, int>((ref, favoriteUserId) async {
  final token  = ref.read(tokenProvider);
  final userId = ref.read(userIdProvider)!;
  final uri = Uri.parse(
      'http://localhost:8080/api/favorite/user/check'
          '?userId=$userId&favoriteUserId=$favoriteUserId'
  );
  final resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
  if (resp.statusCode == 200) {
    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    return data['favorite'] as bool;
  }
  throw Exception('즐겨찾기 여부 조회 실패');
});
