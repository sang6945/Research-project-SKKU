import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindIdState {
  final bool isLoading;
  final bool isFound;
  final String errorMessage;
  final String foundId;

  FindIdState({
    this.isLoading = false,
    this.isFound = false,
    this.errorMessage = '',
    this.foundId = '',
  });

  FindIdState copyWith({
    bool? isLoading,
    bool? isFound,
    String? errorMessage,
    String? foundId,
  }) {
    return FindIdState(
      isLoading: isLoading ?? this.isLoading,
      isFound: isFound ?? this.isFound,
      errorMessage: errorMessage ?? this.errorMessage,
      foundId: foundId ?? this.foundId,
    );
  }
}

class FindIdNotifier extends StateNotifier<FindIdState> {
  FindIdNotifier() : super(FindIdState());

  Future<void> findId({
    required String realName,
    required String phoneNumber,
    required DateTime birth,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '', isFound: false);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/find-id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'realName': realName,
          'phoneNumber': phoneNumber,
          'birth': birth.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        state = state.copyWith(
          isLoading: false,
          isFound: true,
          foundId: responseData['email'] ?? '',
        );
        if (kDebugMode) {
          print(state.foundId);
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorResponse['detail'] ?? '아이디 찾기에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
      );
    }
  }
}

final findIdProvider = StateNotifierProvider<FindIdNotifier, FindIdState>(
      (ref) => FindIdNotifier(),
);
