import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
extension SignInStateExtension on SignInState {
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'realName': realname,
      'nickName': nickName,
      'birth': birth,
      'phoneNumber': phoneNumber,
      'position': position,
      'boolcert1': boolCert1,
      'boolcert2': boolCert2,
      'boolcert3': boolCert3,
      'boolcert4': boolCert4,
    };
  }
}

class SignInState {
  final String email;
  final String password;
  final String realname;
  final String nickName;
  final String birth;
  final String phoneNumber;
  final String position;
  final bool boolCert1;
  final bool boolCert2;
  final bool boolCert3;
  final bool boolCert4;
  final bool isButtonEnabled;

  SignInState({
    this.email = '',
    this.password = '',
    this.realname = '',
    this.nickName = '',
    this.birth = '',
    this.phoneNumber = '',
    this.position = '',
    this.boolCert1 = false,
    this.boolCert2 = false,
    this.boolCert3 = false,
    this.boolCert4 = false,
    this.isButtonEnabled = false,
  });

  SignInState copyWith({
    String? email,
    String? password,
    String? realname,
    String? nickName,
    String? birth,
    String? phoneNumber,
    String? position,
    bool? boolCert1,
    bool? boolCert2,
    bool? boolCert3,
    bool? boolCert4,
    bool? isButtonEnabled,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      realname: realname ?? this.realname,
      nickName: nickName ?? this.nickName,
      birth: birth ?? this.birth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      position: position ?? this.position,
      boolCert1: boolCert1 ?? this.boolCert1,
      boolCert2: boolCert2 ?? this.boolCert2,
      boolCert3: boolCert3 ?? this.boolCert3,
      boolCert4: boolCert4 ?? this.boolCert4,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
    );
  }

  bool get canEnableButton {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        realname.isNotEmpty &&
        nickName.isNotEmpty &&
        birth.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        boolCert1 &&
        boolCert2 &&
        boolCert3; // 필수 약관 동의
  }
}

final signInProvider = StateNotifierProvider<SignInNotifier, SignInState>(
      (ref) => SignInNotifier(),
);

class SignInNotifier extends StateNotifier<SignInState> {
  SignInNotifier() : super(SignInState());

  Future<void> sendDataToBackend() async {
    final url = Uri.parse('http://localhost:8080/api/auth/sign-up'); // API URL
    final payload = state.toJson();
    final bodyString = jsonEncode(payload);
    if (kDebugMode) {
      print('▶️ Request Body: $bodyString');
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: bodyString,
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Data sent successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send data: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending data: $e');
      }
    }
  }

  // 상태 변경 시 로그를 출력하는 메서드
  void _logStateChange(String fieldName, dynamic newValue) {
    if (kDebugMode) {
      print('--- State Updated ---');
    }
    if (kDebugMode) {
      print('$fieldName updated to: $newValue');
    }
    if (kDebugMode) {
      print('Current State: ${state.toJson()}');
    }
    if (kDebugMode) {
      print('----------------------');
    }
  }

  void updateID(String email) {
    state = state.copyWith(email: email);
    _logStateChange('Email', email);
    _checkIfButtonCanBeEnabled();
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
    _logStateChange('Password', password);
    _checkIfButtonCanBeEnabled();
  }

  void updaterealname(String realname) {
    state = state.copyWith(realname: realname);
    _logStateChange('Real Name', realname);
    _checkIfButtonCanBeEnabled();
  }

  void updateNickName(String nickName) {
    state = state.copyWith(nickName: nickName);
    _logStateChange('Nickname', nickName);
    _checkIfButtonCanBeEnabled();
  }

  void updateUserBirth(String birth) {
    state = state.copyWith(birth: birth);
    _logStateChange('Birth', birth);
    _checkIfButtonCanBeEnabled();
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
    _logStateChange('Phone Number', phoneNumber);
    _checkIfButtonCanBeEnabled();
  }

  void updatePosition(String position) {
    state = state.copyWith(position: position);
    _logStateChange('Position', position);
    _checkIfButtonCanBeEnabled();
  }
  void updateCert(bool cert1, bool cert2, bool cert3, bool cert4) {
    state = state.copyWith(boolCert1: cert1, boolCert2: cert2, boolCert3: cert3, boolCert4: cert4);
    _logStateChange('Certifications', [cert1, cert2, cert3, cert4]);
    _checkIfButtonCanBeEnabled();
  }

  void _checkIfButtonCanBeEnabled() {
    final canBeEnabled = state.canEnableButton;
    state = state.copyWith(isButtonEnabled: canBeEnabled);
    _logStateChange('Is Button Enabled', canBeEnabled);
  }
}
