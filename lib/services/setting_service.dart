import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fineplay/data/user_profile.dart';


class SettingService {
  final String baseUrl = 'http://localhost:8080';

  Future<Profile> fetchEditProfile(String token) async {
    final url = Uri.parse('$baseUrl/api/setting/AccountInfo/EditProfile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Profile.fromJson({
        'nickname': data['nickName'],
        'position': data['position'],
        'birthday': data['birth'],
        'email': data['email'],
      });
    } else {
      throw Exception('EditProfile 조회 실패: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> editProfile({
    required String nickname,
    required String position,
    required String birthday,
    required String email,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/api/setting/AccountInfo/EditProfile');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nickname': nickname,
        'position': position,
        'birthday': birthday,
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('프로필 수정 실패: ${response.body}');
    }
  }



}
