import 'dart:convert';
import 'package:http/http.dart' as http;

class Notice {
  final int id;
  final String title;
  final String content;
  final String createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] ?? -1,
      title: json['title'] ?? "",
      content: json['content'] ?? "",
      createdAt: json['createdAt'] ?? "",
    );
  }
}
Future<Notice> fetchNoticeById(int id, String token) async {
  final url = Uri.parse('http://localhost:8080/api/setting/Notice/$id');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonMap = json.decode(utf8.decode(response.bodyBytes));
    final noticeJson = jsonMap['body']; // ✅ 'body' 안에서 꺼냄
    return Notice.fromJson(noticeJson);
  } else {
    throw Exception('Failed to load notice detail');
  }
}


Future<List<Notice>> fetchNotices(String token) async {
  final url = Uri.parse('http://localhost:8080/api/setting/Notice');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
    return jsonList.map((e) => Notice.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load notices');
  }
}
