// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unused_result

import 'package:fineplay/presentation/viewmodel/myteam_list_provider.dart';
import 'package:fineplay/presentation/viewmodel/team_memberlist_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:fineplay/services/team_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:tuple/tuple.dart';

class TeamSettingView extends ConsumerWidget {
  final int teamId;

  const TeamSettingView({
    super.key,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);
    // 1) 팀원 목록 가져오기
    final asyncMembers = ref.watch(teamMemberListProvider(teamId));
    // 2) 현재 로그인된 유저 ID
    final currentUserId = ref.watch(userIdProvider);


    final userToken = ref.watch(tokenProvider);
    final userId = ref.watch(userIdProvider);
    return asyncMembers.when(
        loading: () =>
        const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) =>
            Scaffold(
              body: Center(
                  child: Text('에러: $e', style: const TextStyle(color: Colors.white))),
            ),
        data: (members) {
          // 3) 팀장 userId 뽑아서 비교
          final leaderId = members
              .firstWhere((m) => m.leader)
              .userId;
          final isLeader = leaderId == currentUserId;
          return Scaffold(
            backgroundColor: const Color(0xFF030319),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(88 * S.Y_RATIO),
              child: AppBar(
                automaticallyImplyLeading: false,

                title: Stack(
                  children: [
                    Align(
                        alignment: Alignment.center, // 중앙에 텍스트 배치
                        child: Padding(
                          padding: EdgeInsets.only(top: 25.0 * S.Y_RATIO),
                          child: Text(
                            "팀 설정", // 제목 텍스트
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0 * S.Y_RATIO,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )),
                    Align(
                      alignment: Alignment.centerLeft, // 왼쪽에 뒤로가기 아이콘 배치
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(); // 뒤로가기 기능
                          ref.refresh(teamInfoProvider(
                              Tuple3(userToken, userId!, teamId)));
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 25.0 * S.Y_RATIO, left: 10.0 * S.X_RATIO),
                          // 왼쪽 여백
                          child: Icon(
                            Icons.arrow_back_ios, // 뒤로가기 아이콘
                            color: Colors.white,
                            size: 20.0 * S.Y_RATIO,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF030319),
              ),
            ),
            body: SingleChildScrollView(
              child: SettingmenuWidget(
                teamId: teamId,
                isLeader: isLeader, // <-- 전달
              ),

            ),

          );
        }
    );
  }
}

// 설정메뉴 위젯으로 묶기
class SettingmenuWidget extends ConsumerStatefulWidget {
  final int teamId;
  final bool isLeader;      // <-- 추가

  const SettingmenuWidget({
    super.key,
    required this.teamId,
    required this.isLeader,  // <-- 생성자에 반영

  });

  @override
  _SettingmenuWidgetState createState() => _SettingmenuWidgetState();
}

class _SettingmenuWidgetState extends ConsumerState<SettingmenuWidget> {
  // 각각의 토글 상태 변수
  bool isMatchNotificationOn = false;
  bool isCommunityNotificationOn = false;

  @override

  Widget build(BuildContext context) {
    S.init(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          // 설정 텍스트 위치
          Padding(
            padding: EdgeInsets.only(top: 0 * S.Y_RATIO),
            child: Center(
              child: SizedBox(
                width: S.X_RATIO * 300,
                child: Text(
                  "[일반]",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Wanted sans',
                    fontSize: 18 * S.Y_RATIO,
                    fontWeight: FontWeight.w700

                  ),

                ),

              ),
            ),
          ),

          // 흰색 선
          Padding(
            padding: EdgeInsets.only(top: 10 * S.Y_RATIO),
            child: Center(
              child: SizedBox(
                width: S.X_RATIO * 300,
                child: Container(
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
            child: Center(

              child: GestureDetector(
                onTap: () {
                  _showTeamLeaveDialog(context);
                },
                child: Center(
                  child: SizedBox(
                    width: S.X_RATIO * 300,
                    child: Text(
                      "팀 탈퇴하기",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Wanted sans',
                        fontSize: 16 * S.Y_RATIO,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (widget.isLeader) ...[
            Padding(
              padding: EdgeInsets.only(top: 24 * S.Y_RATIO),
              child: Center(
                child: SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "[팀장]",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Wanted sans',
                      fontSize: 18 * S.Y_RATIO,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10 * S.Y_RATIO),
              child: Center(
                child: SizedBox(
                  width: S.X_RATIO * 300,
                  child: Container(
                    height: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 가입 요청 관리
            Padding(
              padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.pushNamed("managerequest",
                      pathParameters: {'teamId': widget.teamId.toString()}),
                  child: SizedBox(
                    width: S.X_RATIO * 300,
                    child: Text(
                      "가입 요청 관리",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Wanted sans',
                        fontSize: 16 * S.Y_RATIO,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 팀 정보 수정
            Padding(
              padding: EdgeInsets.only(top: 20 * S.Y_RATIO, bottom: 20 * S.Y_RATIO),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.pushNamed("teamediting",
                      pathParameters: {'teamId': widget.teamId.toString()}),
                  child: SizedBox(
                    width: S.X_RATIO * 300,
                    child: Text(
                      "팀 정보 수정",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Wanted sans',
                        fontSize: 16 * S.Y_RATIO,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  void _showTeamLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF21213D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SizedBox(
          width: 300 * S.X_RATIO,
          height: 160 * S.Y_RATIO,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20 * S.Y_RATIO),
              Text(
                "팀 탈퇴",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * S.Y_RATIO,
                  fontFamily: 'Wanted sans',
                  fontWeight: FontWeight.bold,

                ),
              ),
              SizedBox(height: 10 * S.Y_RATIO),
              Text(
                "정말 이 팀에서 \n 탈퇴하시겠습니까?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * S.Y_RATIO,
                  fontFamily: 'Wanted sans',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20 * S.Y_RATIO),
              const Divider(color: Colors.white, thickness: 1, height: 0),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        "아니요",
                        style: TextStyle(color: Color(0xFF9E9E9E), fontFamily: 'Wanted sans',),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40 * S.Y_RATIO,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _leaveTeam(context);
                      },
                      child: const Text(
                        "예",
                        style: TextStyle(color: Colors.redAccent, fontFamily: 'Wanted sans',),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _leaveTeam(BuildContext context) async {
    final token = ref.read(tokenProvider); // 토큰 가져오기
    final userId = ref.read(userIdProvider); // 현재 로그인된 사용자 ID

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/team/TeamLeave'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'teamId': widget.teamId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("팀을 성공적으로 탈퇴했습니다."),),
      );
      Navigator.pop(context); // 팀 설정 페이지 닫기

      ref.invalidate(myTeamListProvider);
      Future.microtask(() {
        Navigator.pop(context); // 두 번째 pop (딜레이 없이 큐에 밀어넣음)
      });
    } else {
      final body = jsonDecode(response.body);
      final errorMessage = body['message'] ?? '알 수 없는 오류가 발생했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}

