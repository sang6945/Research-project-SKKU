import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/Pwre_view.dart';
import 'package:fineplay/presentation/view/setting_view/setting_view.dart';
import 'package:fineplay/presentation/view/notification_view/notification_view.dart';
import 'package:fineplay/presentation/view/PrifileEditView/profile_edit_view.dart';
import 'package:fineplay/presentation/view/account_info_view/withdraw_popup_view.dart';
import 'package:fineplay/presentation/viewmodel/setting_provider.dart'; // ✅ provider import
import 'package:fineplay/presentation/viewmodel/token_provider.dart';   // ✅ token provider import
import 'package:fineplay/utils/custom_appbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AccountInfoView extends ConsumerStatefulWidget {
  const AccountInfoView({super.key});

  @override
  ConsumerState<AccountInfoView> createState() => _AccountInfoViewState();
}

class _AccountInfoViewState extends ConsumerState<AccountInfoView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = ref.read(tokenProvider); // ✅ 토큰 읽기
      ref.read(settingProvider.notifier).loadProfile(token); // ✅ 프로필 불러오기
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    final settingState = ref.watch(settingProvider); // ✅ 상태 구독
    final profile = settingState.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF030319),
      appBar: AppBar(
        leading: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Navigator.pop(context)
            child: Padding(
              padding: EdgeInsets.only(
                top: 32.0 * S.Y_RATIO,
                left: 39.0 * S.X_RATIO,
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 24.0 * S.Y_RATIO,
              ),
            ),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 32 * S.Y_RATIO, left: 39 * S.X_RATIO),
          child: Text(
            "Fine Play",
            style: TextStyle(
              fontSize: 20 * S.Y_RATIO,
              fontFamily: 'GiantsInline',
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF7E1D),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF030319),
        elevation: 0,
        actions: [],
      ),
      body: settingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? const Center(
        child: Text(
          "프로필 정보를 불러올 수 없습니다.",
          style: TextStyle(color: Colors.white, fontFamily: 'Wanted Sans'),
        ),
      )
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 30 * S.X_RATIO),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 헤더
            Padding(
              padding: EdgeInsets.only(
                top: 30 * S.Y_RATIO,
                bottom: 10 * S.Y_RATIO,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "프로필",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * S.Y_RATIO,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Wanted Sans',
                    ),
                  ),
                  SizedBox(height: 10 * S.Y_RATIO),
                  Divider(
                    color: Colors.white,
                    thickness: 1 * S.Y_RATIO,
                  ),
                ],
              ),
            ),

            // 프로필 정보
            Padding(
              padding: EdgeInsets.only(bottom: 20 * S.Y_RATIO),
              child: Row(
                children: [
                  FittedBox(
                    child: Container(
                        width: 60*S.Y_RATIO,
                        height: 60*S.Y_RATIO,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(300.0),
                          child: SvgPicture.asset(
                            'assets/ban/userprofile.svg',
                            fit: BoxFit.cover,
                          ),)
                    ),
                  ),
                  SizedBox(width: 20 * S.X_RATIO),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.nickname,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16 * S.Y_RATIO,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                          SizedBox(width: 5 * S.X_RATIO),
                          // Container(
                          //   width: 8 * S.X_RATIO,
                          //   height: 8 * S.Y_RATIO,
                          //   decoration: const BoxDecoration(
                          //     color: Colors.blue,
                          //     shape: BoxShape.circle,
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 5 * S.Y_RATIO),
                      Text(
                        "${profile.position} / ${profile.birthday}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * S.Y_RATIO,
                          fontFamily: 'Wanted Sans',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.push('/profileedit').then((_) {
                        final token = ref.read(tokenProvider);
                        ref.read(settingProvider.notifier).loadProfile(token);
                      });
                    },
                    child: Text(
                      "수정",
                      style: TextStyle(
                        color: const Color(0xFFFF7E1D),
                        fontSize: 16 * S.Y_RATIO,
                        fontFamily: 'Wanted Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white, thickness: 1 * S.Y_RATIO),

            // 가입 계정
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20 * S.Y_RATIO),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "가입 계정",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16 * S.Y_RATIO,
                      fontFamily: 'Wanted Sans',
                    ),
                  ),
                  SizedBox(height: 10 * S.Y_RATIO),
                  Row(
                    children: [
                      SizedBox(width: 10 * S.X_RATIO),
                      Text(
                        profile.email,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * S.Y_RATIO,
                          fontFamily: 'Wanted Sans',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white, thickness: 1 * S.Y_RATIO),

            // 비밀번호 변경
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    S.init(context);

                    return AlertDialog(
                      backgroundColor: const Color(0xFF1D1C3B),
                      title: Text(
                        '정말 변경하시겠습니까?',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Wanted Sans'),
                      ),
                      content: const Text(
                        '예를 누르시면 로그아웃 됩니다.',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Wanted Sans'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // No 버튼 눌렀을 때 팝업 닫기
                          },
                          child: Text(
                            '아니요',
                            style: TextStyle(color: Colors.white, fontFamily: 'Wanted Sans'),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Pwre_view(),
                              ),
                            );
                          },
                          child: Text(
                            '예',
                            style: TextStyle(color: Colors.grey, fontFamily: 'Wanted Sans'),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              title: Text(
                "비밀번호 변경",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16 * S.Y_RATIO,
              ),
            ),

            // 서비스 탈퇴
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    S.init(context);

                    return WithdrawalPopup(
                      email: profile.email,
                      onWithdrawSuccess: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("탈퇴가 완료되었습니다."),
                          ),
                        );
                      },
                    );
                  },
                ).then((result) {
                  if (result == true) {
                    // TODO: 추가적인 후처리
                  }
                });
              },
              title: Text(
                "서비스 탈퇴",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16 * S.Y_RATIO,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
