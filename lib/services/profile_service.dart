import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fineplay/data/user_profile.dart';

class ProfileService {
  Future<Profile> fetchProfile(String token) async {
    final url = Uri.parse('http://localhost:8080/api/setting/AccountInfo');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Profile.fromJson({
        'nickname': json['nickName'],       // ✅ 키 변환
        'position': json['position'],
        'birthday': json['birth'],          // ✅ 키 변환
        'email': json['email'],
      });
    } else {
      throw Exception('프로필 로딩 실패: ${response.statusCode}');
    }
  }
}
