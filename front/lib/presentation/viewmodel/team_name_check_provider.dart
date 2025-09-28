import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fineplay/presentation/viewmodel/token_provider.dart';

class TeamNameCheckState {
  final bool? isAvailable; // true: 사용 가능, false: 중복, null: 상태 없음
  final String message;

  TeamNameCheckState({this.isAvailable, this.message = ''});

  TeamNameCheckState copyWith({bool? isAvailable, String? message}) {
    return TeamNameCheckState(
      isAvailable: isAvailable ?? this.isAvailable,
      message: message ?? this.message,
    );
  }
}

class TeamNameCheckNotifier extends StateNotifier<TeamNameCheckState> {
  final Ref ref;
  TeamNameCheckNotifier(this.ref) : super(TeamNameCheckState());

  Future<void> checkDuplicate(String teamName) async {
    if (teamName.trim().isEmpty) {
      state = TeamNameCheckState(isAvailable: null, message: '팀 이름을 입력하세요.');
      return;
    }

    final token = ref.read(tokenProvider);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/team/nameDuplicate?TeamName=$teamName'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final useable = json['data']['useable'] as bool;

        state = TeamNameCheckState(
          isAvailable: useable,
          message: useable ? '사용 가능한 팀 이름입니다.' : '이미 사용 중인 팀 이름입니다.',
        );
      } else if (response.statusCode == 409) {
        state = TeamNameCheckState(isAvailable: false, message: '이미 사용 중인 팀 이름입니다.');
      } else {
        state = TeamNameCheckState(isAvailable: null, message: '서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      state = TeamNameCheckState(isAvailable: null, message: '중복 확인 중 오류 발생');
    }
  }

  void reset() {
    state = TeamNameCheckState();
  }
}

final teamNameCheckProvider =
StateNotifierProvider<TeamNameCheckNotifier, TeamNameCheckState>(
      (ref) => TeamNameCheckNotifier(ref),
);
