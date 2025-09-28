// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/presentation/viewmodel/manage_request_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fineplay/presentation/viewmodel/token_provider.dart';

class ManageRequestView extends ConsumerWidget {
  final int teamId;

  const ManageRequestView({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);
    final requestState = ref.watch(manageRequestProvider);
    final requestNotifier = ref.read(manageRequestProvider.notifier);

    Future.microtask(() {
      requestNotifier.fetchRegisterRequests(teamId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF030319),
      body: requestState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('에러 발생: $err')),
        data: (userList) => RefreshIndicator(
          onRefresh: () async {
            await requestNotifier.fetchRegisterRequests(teamId);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              SizedBox(
                height: 28 * S.Y_RATIO,
              ),
              Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft, // 왼쪽에 뒤로가기 아이콘 배치
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // 뒤로가기 기능
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 25.0 * S.Y_RATIO, left: 24.0 * S.X_RATIO),
                        // 왼쪽 여백
                        child: Icon(
                          Icons.arrow_back_ios, // 뒤로가기 아이콘
                          color: Colors.white,
                          size: 20.0 * S.Y_RATIO,
                        ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.center, // 중앙에 텍스트 배치
                      child: Padding(
                        padding: EdgeInsets.only(top: 25.0 * S.Y_RATIO),
                        child: Text(
                          "가입 요청 관리", // 제목 텍스트
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0 * S.Y_RATIO,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )),
                ],
              ),
              SizedBox(height: 30 * S.Y_RATIO),
              Center(
                child: Text(
                  '당기면 새로고침',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12 * S.Y_RATIO,
                    fontFamily: 'Wanted Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 30 * S.Y_RATIO),
              ...userList.map((user) => Padding(
                    padding: EdgeInsets.only(bottom: 10 * S.Y_RATIO),
                    child: PersonalStat(
                      teamId: teamId,
                      userId: user.userId,
                      userName: user.userName,
                      position: user.position,
                      ovr: user.ovr,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class BackButtonBan extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonBan({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 39 * S.Y_RATIO, left: S.X_RATIO * 32),
      child: SizedBox(
        width: 200 * S.X_RATIO,
        height: 22 * S.Y_RATIO,
        child: Stack(
          children: [
            GestureDetector(
              onTap: onPressed,
              child: SvgPicture.asset('assets/ban/back_icon_ban.svg'),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                '가입 요청 관리',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalStat extends ConsumerWidget {
  final String userName;
  final String position;
  final int userId;
  final String ovr;
  final int teamId;

  const PersonalStat(
      {super.key,
      required this.userName,
      required this.position,
      required this.userId,
      required this.ovr,
      required this.teamId});

  Color getPositionColor(String position) {
    switch (position.toUpperCase()) {
      case 'MF':
        return const Color(0xFF00D68F).withOpacity(0.8);
      case 'DF':
        return const Color(0xFF3028FF).withOpacity(0.8);
      default:
        return const Color(0xFFFF381E).withOpacity(0.8);
    }
  }

  Future<void> acceptJoinRequest({
    required WidgetRef ref,
    required int teamId,
    required int userId,
  }) async {
    final token = ref.read(tokenProvider);
    final url = Uri.parse('http://localhost:8080/api/team/TeamAccept');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'teamId': teamId,
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('수락 요청 실패: ${response.body}');
    }
  }

  Future<void> rejectJoinRequest({
    required WidgetRef ref,
    required int teamId,
    required int userId,
  }) async {
    final token = ref.read(tokenProvider);
    final url = Uri.parse(
        'http://localhost:8080/api/team/TeamReject'); // 에뮬레이터에서는 localhost → localhost

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'teamId': teamId,
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('거절 요청 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(children: [
      Center(
          child: Stack(
              children: [
      Container(
        height: S.Y_RATIO * 154,
        width: S.X_RATIO * 300,
        decoration: BoxDecoration(
          color: const Color(0xFF21213F),
          borderRadius: BorderRadius.circular(S.X_RATIO * 15.0),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 40 * S.X_RATIO,
              top: 20 * S.Y_RATIO,
              child: SizedBox(
                width: 44 * S.X_RATIO, // 네모박스와 동일한 너비
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: S.Y_RATIO * 44,
                        width: S.X_RATIO * 44,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child:
                              SvgPicture.asset(
                            'assets/ban/userprofile.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: S.Y_RATIO * 4,
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // 한 줄(maxLines:1)로 그려보고
                          final tp = TextPainter(
                            text: TextSpan(
                              text: userName,
                              style: TextStyle(
                                fontSize: 12 * S.Y_RATIO,
                                fontFamily: 'Wanted sans',
                              ),
                            ),
                            maxLines: 2,
                            textDirection: TextDirection.ltr,
                          )..layout(maxWidth: constraints.maxWidth);
                          // 한 줄로 안 들어가면 크기를 10으로
                          final fontSize = tp.didExceedMaxLines
                              ? 10 * S.Y_RATIO
                              : 12 * S.Y_RATIO;
                          return Text(
                            userName,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontFamily: 'Wanted sans',
                            ),
                          );
                        },
                      ),
                    ]),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 133 * S.X_RATIO,
                top: 22 * S.Y_RATIO,
              ),
              child: SizedBox(
                width: S.X_RATIO * 50,
                child: Column(
                  children: [
                    Text(
                      '포지션',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0 * S.Y_RATIO,
                        fontFamily: 'Wanted Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: S.Y_RATIO * 14),
                    Container(
                      height: S.Y_RATIO * 30,
                      width: S.X_RATIO * 50,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(S.X_RATIO * 10.0),
                        color: getPositionColor(position),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4.0,
                            spreadRadius: 0.0,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(position,
                            style: TextStyle(
                                fontSize: S.Y_RATIO * 16,
                                fontFamily: 'Wanted Sans',
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 213 * S.X_RATIO,
                top: 22 * S.Y_RATIO,
              ),
              child: SizedBox(
                width: S.X_RATIO * 50,
                child: Column(
                  children: [
                    Text(
                      'OVR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0 * S.Y_RATIO,
                        fontFamily: 'Wanted Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: S.Y_RATIO * 14),
                    Container(
                      height: S.Y_RATIO * 30,
                      width: S.X_RATIO * 50,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(S.X_RATIO * 10.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4.0,
                            spreadRadius: 0.0,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(ovr,
                            style: TextStyle(
                                fontSize: S.Y_RATIO * 16,
                                fontFamily: 'Wanted Sans',
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF21213F))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: S.Y_RATIO * 104.0, left: 10 * S.X_RATIO),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        await acceptJoinRequest(
                            ref: ref, teamId: teamId, userId: userId);
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: const Color(0xFF21213D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SizedBox(
                              width: 300 * S.X_RATIO,
                              height: 160 * S.Y_RATIO,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: 45 * S.Y_RATIO,
                                        left: 74 * S.X_RATIO),
                                    child: const Text(
                                      '가입 요청을 수락했어요.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Wanted Sans',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 90 * S.Y_RATIO),
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: 200 * S.X_RATIO,
                                          height: 44 * S.Y_RATIO,
                                          decoration: ShapeDecoration(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFBCBCBC)),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              '확인',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'Wanted Sans',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('수락 실패: ${e.toString()}')),
                        );
                      }
                    },
                    child: Container(
                      width: 135 * S.X_RATIO,
                      height: 36 * S.Y_RATIO,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFF7400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '수락',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * S.Y_RATIO,
                              fontFamily: 'Wanted Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10 * S.X_RATIO,
                  ),
                  GestureDetector(
                      onTap: () async {
                        try {
                          await rejectJoinRequest(
                              ref: ref, teamId: teamId, userId: userId);
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: const Color(0xFF21213D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SizedBox(
                                width: 300 * S.X_RATIO,
                                height: 160 * S.Y_RATIO,
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 45 * S.Y_RATIO,
                                          left: 74 * S.X_RATIO),
                                      child: const Text(
                                        '가입 요청을 거절했어요.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Wanted Sans',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 90 * S.Y_RATIO),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            width: 150 * S.X_RATIO,
                                            height: 44 * S.Y_RATIO,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    width: 1,
                                                    color:
                                                        Color(0xFFBCBCBC)),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '확인',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16 * S.Y_RATIO,
                                                  fontFamily: 'Wanted Sans',
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('거절 실패: ${e.toString()}')),
                          );
                        }
                      },
                      child: Container(
                        width: 135 * S.X_RATIO,
                        height: 36 * S.Y_RATIO,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFBCBCBC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '거절',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * S.Y_RATIO,
                                fontFamily: 'Wanted Sans',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
              ],
            ))
    ]);
  }
}
