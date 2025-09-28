// lib/presentation/viewmodel/pwre2_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pwre2State {
  final bool isLoading;
  final String errorMessage;
  final bool passwordChanged;

  Pwre2State({
    this.isLoading = false,
    this.errorMessage = '',
    this.passwordChanged = false,
  });

  Pwre2State copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? passwordChanged,
  }) {
    return Pwre2State(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      passwordChanged: passwordChanged ?? this.passwordChanged,
    );
  }
}

class Pwre2Notifier extends StateNotifier<Pwre2State> {
  Pwre2Notifier() : super(Pwre2State());

  /// 2단계: 비밀번호 변경 (type=setNewPassword)
  Future<void> setNewPassword({
    required String email,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    final uri = Uri.parse('http://localhost:8080/api/auth/password');
    final body = {
      'type': 'setNewPassword',
      'email': email,
      'newPassword': newPassword,
    };

    try {
      final resp = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (resp.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          passwordChanged: true,
        );
      } else {
        final err = jsonDecode(resp.body);
        state = state.copyWith(
          isLoading: false,
          errorMessage: err['message'] ?? '비밀번호 변경에 실패했습니다.',
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
    state = Pwre2State();
  }
}

final pwre2Provider = StateNotifierProvider<Pwre2Notifier, Pwre2State>(
      (ref) => Pwre2Notifier(),
);