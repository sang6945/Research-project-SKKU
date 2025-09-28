import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/services/setting_service.dart';
import 'package:fineplay/data/user_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ✅ 상태 클래스
class SettingState {
  final bool isLoading;
  final bool isSuccess;
  final String errorMessage;
  final Profile? profile;
  final bool communityAlarm;
  final bool matchAlarm;

  SettingState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.profile,
    this.communityAlarm = false,
    this.matchAlarm = false,
  });

  SettingState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    Profile? profile,
    bool? communityAlarm,
    bool? matchAlarm,
  }) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      profile: profile ?? this.profile,
      communityAlarm: communityAlarm ?? this.communityAlarm,
      matchAlarm: matchAlarm ?? this.matchAlarm,
    );
  }
}

/// ✅ 상태 관리 클래스
class SettingNotifier extends StateNotifier<SettingState> {
  final String baseUrl = 'http://localhost:8080';
  final SettingService _service;

  SettingNotifier(this._service) : super(SettingState());

  void setAlarm(String type, bool value) {
    if (type == 'matchAlarm') {
      state = state.copyWith(matchAlarm: value);
    } else if (type == 'communityAlarm') {
      state = state.copyWith(communityAlarm: value);
    }
  }

  void updatePosition(String newPosition) {
    final current = state.profile;
    if (current != null) {
      final updatedProfile = Profile(
        nickname: current.nickname,
        position: newPosition,
        birthday: current.birthday,
        email: current.email,
        realName: current.realName,
        phoneNumber: current.phoneNumber,
      );
      state = state.copyWith(profile: updatedProfile);
    }
  }


  // 닉네임 중복 확인 메소드 추가
  Future<bool> checkNicknameDuplicate(String nickname, String token) async {
    final url = Uri.parse('http://localhost:8080/api/auth/check-nick-duplicate');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'nickName': nickname}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['status'] != 'EXISTS'; // 중복이 아닌 경우 true, 중복인 경우 false
    } else {
      throw Exception('닉네임 중복 확인 실패: ${response.body}');
    }
  }

  Future<void> loadEditProfile(String token) async {
    state = state.copyWith(isLoading: true, errorMessage: '', isSuccess: false);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/setting/AccountInfo/EditProfile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('[DEBUG] status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('[DEBUG] body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profileData = data.containsKey('data') ? data['data'] : data;

        final profile = Profile.fromJson({
          'nickname': profileData['nickName'],
          'position': profileData['position'],
          'birthday': profileData['birth'],
          'email': profileData['email'],
        });

        state = state.copyWith(profile: profile, isLoading: false);
      } else {
        if (kDebugMode) {
          print('[ERROR] 서버 오류: ${response.statusCode}');
        }
        state = state.copyWith(errorMessage: '서버 오류', isLoading: false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[EXCEPTION] $e');
      }
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }






  // 이게 아마 죽은 코드일걸.
  // Future<void> editProfile({
  //   required String nickname,
  //   required String position,
  //   required String birthday,
  //   required String email,
  //   required String token,
  // }) async {
  //   state = state.copyWith(isLoading: true, errorMessage: '', isSuccess: false);
  //   try {
  //     await _service.editProfile(
  //       nickname: nickname,
  //       position: position,
  //       birthday: birthday,
  //       email: email,
  //       token: token,
  //     );
  //     state = state.copyWith(isSuccess: true, isLoading: false);
  //   } catch (e) {
  //     state = state.copyWith(errorMessage: e.toString(), isLoading: false);
  //   }
  // }


  Future<void> loadProfile(String token) async {
      state = state.copyWith(isLoading: true, errorMessage: '', isSuccess: false);
      try {
        final response = await http.get(
          Uri.parse('http://localhost:8080/api/setting/AccountInfo'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final profile = Profile.fromJson({
            'nickname': data['nickName'],
            'position': data['position'],
            'birthday': data['birth'],
            'email': data['email'],
          });

          state = state.copyWith(profile: profile, isLoading: false);
        } else {
          throw Exception('서버 오류: ${response.statusCode}');
        }
      } catch (e) {
        state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      }
    }




  Future<void> loadAlarmSettings(String token) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/setting'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          matchAlarm: data['matchAlarm'],
          communityAlarm: data['communityAlarm'],
          isLoading: false,
        );
      } else {
        throw Exception('서버 응답 오류');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '알림 설정 로딩 실패: $e',
      );
    }
  }

  Future<void> updateAlarmSetting(String token, String type, bool value) async {
    final url = Uri.parse('http://localhost:8080/api/setting/UpdateAlarm');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'type': type,
      'value': value,
    });

    final response = await http.patch(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("🔄 알림 설정 업데이트 성공");
      }
      setAlarm(type, value);
    } else {
      if (kDebugMode) {
        print("❌ 알림 설정 업데이트 실패: ${response.body}");
      }
    }
  }
}

/// ✅ Provider
final settingProvider = StateNotifierProvider<SettingNotifier, SettingState>(
      (ref) => SettingNotifier(SettingService()),
);
