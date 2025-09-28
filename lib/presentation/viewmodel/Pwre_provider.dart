// lib/presentation/viewmodel/pwre_provider.dart

// ignore_for_file: file_names

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PwreState {
  final bool isLoading;
  final String errorMessage;
  final bool userFound;
  final String email;

  PwreState({
    this.isLoading = false,
    this.errorMessage = '',
    this.userFound = false,
    this.email = '',
  });

  PwreState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? userFound,
    String? email,
  }) {
    return PwreState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userFound: userFound ?? this.userFound,
      email: email ?? this.email,
    );
  }
}

class PwreNotifier extends StateNotifier<PwreState> {
  PwreNotifier() : super(PwreState());

  Future<void> findUser({
    required String realName,
    required String email,
    required String phoneNumber,
    required DateTime birth,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    final uri = Uri.parse('http://localhost:8080/api/auth/password');
    final body = {
      'type': 'findUser',
      'realName': realName,
      'email': email,
      'phoneNumber': phoneNumber,
      'birth': '${birth.year.toString().padLeft(4, '0')}-'
          '${birth.month.toString().padLeft(2, '0')}-'
          '${birth.day.toString().padLeft(2, '0')}',
    };

    try {
      final resp = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = jsonDecode(resp.body);

      if (resp.statusCode == 200 && data['code'] == 'SFU') {
        state = state.copyWith(
          isLoading: false,
          userFound: true,
          email: email,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          userFound: false,
          errorMessage: data['message'] ?? '사용자 확인에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '네트워크 오류가 발생했습니다.',
      );
    }
  }

  void reset() {
    state = PwreState();
  }
}

final pwreProvider = StateNotifierProvider<PwreNotifier, PwreState>(
      (ref) => PwreNotifier(),
);