// ignore_for_file: non_constant_identifier_names

import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final bool isLoggedIn;
  final String errorMessage;

  LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isLoggedIn = false,
    this.errorMessage = '',
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? isLoggedIn,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  final Ref ref;
  LoginNotifier(this.ref) : super(LoginState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  Future<void> login(BuildContext context) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': state.email,
          'password': state.password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        final userId= responseData['userId'];
        ref.read(tokenProvider.notifier).state = token;
        ref.read(userIdProvider.notifier).state = userId;
        // final userIdStr=userId.toString();
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
        );
        if (kDebugMode) {
          print('로그인 성공! 토큰: $token');
        }
        if (kDebugMode) {
          print(state.isLoggedIn);
        }
        remove_privacy();
        if (kDebugMode) {
          print(state.email);
        }
        // 여기서 토큰을 로컬 저장소에 저장하거나 다른 작업을 수행할 수 있습니다.


        // 로그인 성공 시 SSE 연결 시작

        // await ref.read(sseProvider.notifier).startSseConnection(userIdStr, token);  // SSE 연결을 위한 provider 호출


      } else {
        final errorResponse = jsonDecode(response.body);
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorResponse['detail'] ?? '로그인에 실패했습니다.',
        );
        if (kDebugMode) {
          print('로그인 오류: ${state.errorMessage}');
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
      );
      if (kDebugMode) {
        print('네트워크 오류: $e');
      }

    }
  }

  void logout() {
    state = state.copyWith(
      isLoggedIn: false,
      email: '',
      password: '',
      errorMessage: '',
    );
  }

  void remove_privacy() {
    state=state.copyWith(
      email: '',
      password: '',
    );
  }

  // void _showErrorDialog(BuildContext context, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text('오류'),
  //       content: Text(message),
  //       actions: <Widget>[
  //         TextButton(
  //           child: Text('확인'),
  //           onPressed: () {
  //             Navigator.of(ctx).pop();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
      (ref) => LoginNotifier(ref),
);
