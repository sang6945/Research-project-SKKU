import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

class NotificationResponseDto {
  final int id;
  final String type;
  final String title;
  final String content;
  final String createdAt;
  final int userId;
  final int? teamId;
  final int? matchId;
  final String status;

  NotificationResponseDto({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.userId,
    this.teamId,
    this.matchId,
    required this.status,
  });

  factory NotificationResponseDto.fromJson(Map<String, dynamic> json) {
    return NotificationResponseDto(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      userId: json['userId'] as int,
      teamId: json['teamId'] as int?,
      matchId: json['matchId'] as int?,
      status: json['status'] as String,
    );
  }
}

final notificationListProvider = FutureProvider.autoDispose
    .family<List<NotificationResponseDto>, Tuple2<int, String>>(
      (ref, params) async {
    final userId = params.item1;
    final authToken = params.item2;
    final response = await http.get(
      Uri.parse('http://localhost:8080/sse/notifications?userId=$userId'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> arr = jsonDecode(response.body) as List<dynamic>;
      return arr
          .map((e) =>
          NotificationResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('알림 목록 조회 실패: ${response.body}');
    }
  },
);

class NotificationService {
  final String authToken;
  NotificationService(this.authToken);

  Future<void> deleteNotification(int notificationReceiverId) async {
    final response = await http.delete(
      Uri.parse(
          'http://localhost:8080/sse/notifications/$notificationReceiverId'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('알림 삭제 실패: ${response.body}');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final token = ref.read(tokenProvider);
  return NotificationService(token);
});