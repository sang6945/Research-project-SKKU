// lib/presentation/viewmodel/team_editing_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// 팀 수정 화면에서 관리할 상태
class TeamEditingState {
  final int teamId;
  final String originalName;
  final String teamName;
  final String homeTown1;
  final String homeTown2;
  final bool isNameChecked;
  final bool isNameValid;
  final String message;

  TeamEditingState({
    required this.teamId,
    this.originalName = '',
    this.teamName = '',
    this.homeTown1 = '',
    this.homeTown2 = '',
    this.isNameChecked = false,
    this.isNameValid = true,
    this.message = '',
  });

  TeamEditingState copyWith({
    String? originalName,
    String? teamName,
    String? homeTown1,
    String? homeTown2,
    bool? isNameChecked,
    bool? isNameValid,
    String? message,
  }) {
    return TeamEditingState(
      teamId: teamId,
      originalName: originalName ?? this.originalName,
      teamName: teamName ?? this.teamName,
      homeTown1: homeTown1 ?? this.homeTown1,
      homeTown2: homeTown2 ?? this.homeTown2,
      isNameChecked: isNameChecked ?? this.isNameChecked,
      isNameValid: isNameValid ?? this.isNameValid,
      message: message ?? this.message,
    );
  }
}

/// 실제 로직을 처리하는 Notifier
class TeamEditingNotifier extends StateNotifier<TeamEditingState> {
  TeamEditingNotifier(int teamId)
      : super(TeamEditingState(teamId: teamId));

  /// 1) 서버에서 기존 팀 정보를 가져와 초기화
  Future<void> loadTeam({
    required String token,
    required int userId,
  }) async {
    final uri = Uri.parse('http://localhost:8080/api/teamInfo');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'userId': userId,
        'teamId': state.teamId,
      }),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      // 2) homeTown 문자열을 띄어쓰기 하나로 분리
      final homeTownRaw = data['homeTown'] as String? ?? '';
      final parts = homeTownRaw.split(RegExp(r'\s+'));
      final home1 = parts.isNotEmpty ? parts[0] : '';
      final home2 = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      state = state.copyWith(
        originalName: data['teamName'] as String? ?? '',
        teamName:     data['teamName'] as String? ?? '',
        homeTown1:    home1,
        homeTown2:    home2,
      );
    } else {
      throw Exception('팀 정보 로드 실패 (${res.statusCode})');
    }
  }

  /// 2) 이름 입력 시 상태 업데이트
  void updateName(String name) {
    String msg = '';
    bool valid;

    if (name.isEmpty) {
      valid = false;
      msg = '팀 이름을 입력해주세요.';
    } else if (!RegExp(r'^[가-힣a-zA-Z0-9]{1,8}$').hasMatch(name)) {
      valid = false;
      msg = '팀 이름은 8글자 이내로 국문•영문•숫자만 가능합니다.';
    } else {
      valid = true;
      msg = '';
    }

    state = state.copyWith(
      teamName: name,
      isNameChecked: false,
      isNameValid: valid,
      message: msg,
    );
  }

  void setNameChecked(bool isChecked, bool isValid) {
    state = state.copyWith(
      isNameChecked: isChecked,
      isNameValid: isValid,
    );
  }

  /// 3) 중복 체크: 기존 이름과 다를 때만 호출
  Future<void> checkDuplicate(String token) async {
    if (state.teamName == state.originalName) {
      state = state.copyWith(isNameChecked: true, isNameValid: true,   message: '');
      return;
    }
    final res = await http.get(
      Uri.parse(
        'http://localhost:8080/api/team/nameDuplicate?TeamName=${state.teamName}',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final body = json.decode(res.body);
    final useable = body['data']?['useable'] as bool? ?? false;
    final msg    = body['message'] as String? ?? '';


    if (useable) {
      state = state.copyWith(
        isNameChecked: true,
        isNameValid: true,
        message: '',
      );
    } else {
      state = state.copyWith(
        isNameChecked: false,
        isNameValid: false,
        message: msg,               // "중복된 팀 이름"
      );

    }


  }

  /// 4) PUT 요청으로 팀 정보 수정
  Future<void> updateTeam(String token) async {
    final res = await http.put(
      Uri.parse('http://localhost:8080/api/team/TeamUpdate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'teamID': state.teamId,
        'teamName': state.teamName,
        'homeTown1': state.homeTown1,
        'homeTown2': state.homeTown2,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('팀 수정 실패: ${res.body}');
    }
  }

  /// 5) 연고지(시/도) 업데이트
  void updateHometown1(String city) {
    state = state.copyWith(homeTown1: city);
  }

  /// 6) 연고지(군/구) 업데이트
  void updateHometown2(String district) {
    state = state.copyWith(homeTown2: district);
  }

  /// 7) 상태 초기화 (뒤로 가기 등)
  void reset() {
    state = TeamEditingState(teamId: state.teamId);
  }
}

/// 팀 ID별로 Provider 생성
final teamEditingProvider = StateNotifierProvider.autoDispose
    .family<TeamEditingNotifier, TeamEditingState, int>(
      (ref, teamId) => TeamEditingNotifier(teamId),
);
