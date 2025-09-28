import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:fineplay/presentation/viewmodel/token_provider.dart';

/// 가입 신청자 모델
class RegisterRequestUser {
  final String userName;
  final String position;
  final int userId;
  final String ovr;

  RegisterRequestUser({
    required this.userName,
    required this.position,
    required this.userId,
    required this.ovr,
  });

  factory RegisterRequestUser.fromJson(Map<String, dynamic> json) {
    return RegisterRequestUser(
      userName: json['userName'],
      position: json['position'],
      userId: json['userId'],
      ovr: json['ovr'],
    );
  }
}

/// 상태 관리 로직
class ManageRequestNotifier extends StateNotifier<AsyncValue<List<RegisterRequestUser>>> {
  final Ref ref;

  ManageRequestNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> fetchRegisterRequests(int teamId) async {
    final token = ref.read(tokenProvider);
    final url = Uri.parse('http://localhost:8080/api/team/TeamRegisterManage');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'teamId': teamId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = jsonDecode(response.body);
        final List<dynamic> dataList = jsonBody['data'];

        final users = dataList
            .map((userJson) => RegisterRequestUser.fromJson(userJson))
            .toList();

        state = AsyncValue.data(users);
      } else {
        state = AsyncValue.error('서버 오류: ${response.statusCode}', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error('네트워크 오류: $e', st);
    }
  }
}

/// Provider 선언
final manageRequestProvider =
StateNotifierProvider<ManageRequestNotifier, AsyncValue<List<RegisterRequestUser>>>(
        (ref) => ManageRequestNotifier(ref));
