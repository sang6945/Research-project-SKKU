// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:fineplay/presentation/viewmodel/myteam_list_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/login_provider.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:fineplay/utils/screen_ratio.dart';


class WithdrawalPopup extends ConsumerStatefulWidget {
  final String email;
  final Function onWithdrawSuccess;

  const WithdrawalPopup({
    super.key,
    required this.email,
    required this.onWithdrawSuccess,
  });

  @override
  ConsumerState<WithdrawalPopup> createState() => _WithdrawalPopupState();
}

class _WithdrawalPopupState extends ConsumerState<WithdrawalPopup> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _confirmStage = false;

  Future<void> _handleCheck() async {
    final String password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorMessage = '비밀번호를 입력해주세요.');
      return;
    }

    final token = ref.read(tokenProvider);
    final url = Uri.parse(
        "http://localhost:8080/api/setting/AccountInfo/withdraw/CheckPassword");

    final body = jsonEncode({
      "email": widget.email,
      "password": password,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      // if (response.statusCode == 200) {
      //
      //
      //   setState(() {
      //     _errorMessage = null;
      //     _confirmStage = true;
      //   });
      // } else {
      //   setState(() {
      //     _errorMessage = '비밀번호가 틀렸어요!';
      //     _passwordController.clear();
      //   });
      // }
      final Map<String, dynamic> data = jsonDecode(response.body);
      final bool pwdCorrect = data['passwordCorrect'] as bool? ?? false;

      if (response.statusCode == 200) {
        if (pwdCorrect) {
          setState(() {
            _confirmStage = true;
          });
        } else {
          setState(() {
            _confirmStage = false;
            _errorMessage = '비밀번호가 틀렸어요!';
            _passwordController.clear();
          });
        }
      }
    } catch (e) {
      setState(() => _errorMessage = '서버와 통신할 수 없습니다.');
    }
  }

  Future<void> _handleWithdraw() async {
    final token = ref.read(tokenProvider);
    final url = Uri.parse(
        "http://localhost:8080/api/setting/AccountInfo/withdraw/WithdrawService");

    try {
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = data['message'] as String? ?? '';

        if (message == "회원 탈퇴 완료") {
          // 1) 팝업 닫기
          Navigator.of(context).pop();

          // 2) 로그인 상태 클리어
          ref.read(loginProvider.notifier).logout();

          // 3) 로그인 화면으로 이동
          context.go('/');

          // 콜백도 호출해 주고 싶으면
          widget.onWithdrawSuccess();
        } else {
          setState(() => _errorMessage = message);
        }
      } else {
        setState(() => _errorMessage = '탈퇴 요청이 실패했어요.');
      }
    } catch (e) {
      setState(() => _errorMessage = '서버와 통신할 수 없습니다.');
    }
  }

  Future<void> _handleLeaveAllTeamsAndWithdraw() async {
    final token = ref.read(tokenProvider);
    final userId = ref.read(userIdProvider);
    final teamListAsync = ref.read(myTeamListProvider);

    if (teamListAsync is! AsyncData<TeamListResult>) {
      setState(() {
        _errorMessage = '팀 정보 로딩에 실패했습니다. 잠시 후 다시 시도해주세요.';
      });
      return;
    }

    final teams = teamListAsync.value.data;
    final url = Uri.parse("http://localhost:8080/api/team/TeamLeave");

    if (userId == null) {
      setState(() {
        _errorMessage = '로그인 정보가 만료되었거나 유효하지 않습니다.';
      });
      return;
    }

    for (final team in teams) {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "teamId": team.teamId,
          "userId": userId,
        }),
      );
      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = '팀 탈퇴에 실패했습니다. 다시 시도해주세요.';
        });
        return;
      }
    }

    // 모든 팀 탈퇴 성공 후 기존 서비스 탈퇴 함수 호출 (내부에서 메시지와 팝업, 라우팅, 콜백 등 유지됨)
    await _handleWithdraw();
  }

  void _handleCancel() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1C3B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: _confirmStage ? _buildConfirmContent() : _buildPasswordInput(),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('탈퇴할 계정의 비밀번호를 입력해주세요.',
            style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        if (_errorMessage != null)
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            filled: true,
            fillColor: Colors.transparent,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleCheck,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        )
      ],
    );
  }

  Widget _buildConfirmContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('정말로... 탈퇴할까요?', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton(
                onPressed: _handleCancel,
                child: const Text('아니요', style: TextStyle(color: Colors.white)),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: _handleLeaveAllTeamsAndWithdraw,
                child: const Text('탈퇴', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
