// ignore_for_file: unused_result

import 'package:fineplay/services/team_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/presentation/viewmodel/team_memberlist_provider.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tuple/tuple.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';

class TeamMemberlistView extends ConsumerWidget {
  final int teamId;
  const TeamMemberlistView({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);
    final userToken = ref.watch(tokenProvider);
    final userId = ref.watch(userIdProvider);
    final asyncMembers = ref.watch(teamMemberListProvider(teamId));

    return Scaffold(
      backgroundColor: const Color(0xFF030319),
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: Stack(
          children: [
            Align(
                alignment: Alignment.center, // 중앙에 텍스트 배치
                child: Padding(
                  padding: EdgeInsets.only(top: 25.0 * S.Y_RATIO),
                  child: Text(
                    "팀원 목록", // 제목 텍스트
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
                  ref.refresh(teamInfoProvider(Tuple3(userToken, userId!, teamId)));

                },
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 25.0 * S.Y_RATIO, left: 10.0 * S.X_RATIO), // 왼쪽 여백
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

      body: asyncMembers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('에러: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (members) {
          final leaders = members.where((m) => m.leader).toList();
          final normals = members.where((m) => !m.leader).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 팀장 섹션
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
                            fontWeight: FontWeight.w700

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
                ...leaders.map((m) => TeamMemberCard(nickName: m.nickName, ovr: m.ovr)),
                // 일반 팀원 섹션
                Padding(
                  padding: EdgeInsets.only(top: 24 * S.Y_RATIO),
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
                ...normals.map((m) => TeamMemberCard(nickName: m.nickName, ovr: m.ovr)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 섹션 제목
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Padding(
      padding: EdgeInsets.only(top: 24 * S.Y_RATIO),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18 * S.Y_RATIO,
          fontWeight: FontWeight.w700,
          fontFamily: 'Wanted sans',
        ),
      ),
    );
  }
}

// 기존 하드코딩 UI를 그대로 재사용한 카드
class TeamMemberCard extends StatelessWidget {
  final String nickName;
  final String ovr;
  const TeamMemberCard({super.key, required this.nickName, required this.ovr});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Padding(
      padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
      child: Center(
        child: Container(
          height: 100 * S.Y_RATIO,
          width: 300 * S.X_RATIO,
          decoration: BoxDecoration(
            color: const Color(0xFF21213F),
            borderRadius: BorderRadius.circular(15 * S.Y_RATIO),
          ),
          child: Stack(
            children: [
              // 왼쪽: 프로필 아이콘 + 닉네임
              Padding(
                padding: EdgeInsets.only(left: 22 * S.X_RATIO),
                child: SizedBox(
                  width: 60 * S.Y_RATIO,
                  height: 120 * S.Y_RATIO,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: 15 * S.Y_RATIO,
                          bottom: 4 * S.Y_RATIO,
                        ),
                        child: SizedBox(
                          height: 44 * S.Y_RATIO,
                          width: 44 * S.Y_RATIO,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: SvgPicture.asset(
                                'assets/ban/userprofile.svg',
                                fit: BoxFit.cover,
                              ),)
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // 한 줄(maxLines:1)로 그려보고
                          final tp = TextPainter(
                            text: TextSpan(
                              text: nickName,
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
                              ? 12 * S.Y_RATIO
                              : 12 * S.Y_RATIO;
                          return Text(
                            nickName,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontFamily: 'Wanted sans',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 오른쪽: OVR
              Row(
                children: [
                  SizedBox(width: 125 * S.X_RATIO),
                  Center(
                    child: Row(
                      children: [
                        Text(
                          'OVR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * S.Y_RATIO,
                            fontFamily: 'Wanted Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 25 * S.X_RATIO),
                        Container(color: Colors.white, width: 1, height: 20),
                        SizedBox(width: 25 * S.X_RATIO),
                        Container(
                          width: 50 * S.X_RATIO,
                          height: 32 * S.Y_RATIO,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              ovr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF21213F),
                                fontSize: 16 * S.Y_RATIO,
                                fontFamily: 'Wanted Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
