import 'package:fineplay/presentation/viewmodel/favorite_user_list_provider.dart';
import 'package:fineplay/presentation/viewmodel/home_provider.dart';
import 'package:fineplay/presentation/viewmodel/hometeamlist_provider.dart';
import 'package:fineplay/presentation/viewmodel/my_team_info_provider.dart';
import 'package:fineplay/presentation/viewmodel/mypage_service_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:fineplay/services/mypage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/presentation/viewmodel/login_provider.dart';
import 'dart:async';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:go_router/go_router.dart';
import 'package:fineplay/presentation/viewmodel/setting_provider.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fineplay/router/app_router.dart';

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

class SettingView extends ConsumerWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    // WillPopScope: 뒤로가기 시 상태 정리
    Future<bool> onWillPop() async {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        ref.invalidate(homeProvider(userId));
        ref.invalidate(hometeamListProvider(userId));
        ref.invalidate(favoriteUserListProvider);
        final token = ref.read(tokenProvider);
        await ref
            .read(myTeamInfoProvider.notifier)
            .loadInitialTeamInfo(userId: userId, token: token);
        ref.invalidate(mypageProvider);
        ref.invalidate(mypageServiceProvider);
      }
      return true;
    }

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF030319),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70 * S.Y_RATIO),
          child: AppBar(
            // 좌측 상단 뒤로가기 버튼
            leading: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap:() async {
                  final userId = ref.read(userIdProvider);
                  if (userId != null) {
                    ref.invalidate(homeProvider(userId));
                    ref.invalidate(hometeamListProvider(userId));
                    ref.invalidate(favoriteUserListProvider);
                    final token = ref.read(tokenProvider);
                    await ref
                        .read(myTeamInfoProvider.notifier)
                        .loadInitialTeamInfo(userId: userId, token: token);
                    ref.invalidate(mypageProvider);
                    ref.invalidate(mypageServiceProvider);
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
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
            // 타이틀
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
            actions: const [], // 상단 아이콘 제거
          ),
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              SettingmenuWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingmenuWidget extends ConsumerStatefulWidget {
  const SettingmenuWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingmenuWidgetState createState() => _SettingmenuWidgetState();
}

class _SettingmenuWidgetState extends ConsumerState<SettingmenuWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final token = ref.read(tokenProvider);
      ref.read(settingProvider.notifier).loadAlarmSettings(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    final settingState = ref.watch(settingProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30 * S.Y_RATIO),
            child: Center(
              child: SizedBox(
                width: S.X_RATIO * 300,
                child: Text(
                  "설정",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Wanted sans',
                    fontSize: 18 * S.Y_RATIO,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40 * S.Y_RATIO),
            child: Center(
              child: Container(
                  width: S.X_RATIO * 300, height: 1, color: Colors.white),
            ),
          ),
          // 계정 정보
          Padding(
            padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
            child: GestureDetector(
              onTap: () {
                  context.push("/accountinfo");},
              child: Center(
                child: SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "계정 정보",
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

          // 푸시 알림 (단일 스위치)
          buildSwitchRow(
            '푸시 알림',
            settingState.matchAlarm,
            'matchAlarm',
          ),
          Padding(
            padding: EdgeInsets.only(top: 40 * S.Y_RATIO),
            child: Center(child: Container(
                width: S.X_RATIO * 300, height: 1, color: Colors.white)),
          ),
          // 공지 사항 (16pt)
          Padding(
            padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  context.push("/noticelist");
                },
                child: SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "공지 사항",
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
          // 이용 약관 (16pt)
          Padding(
            padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _launchUrl('https://www.instagram.com/fineplay.kr/');
                },
                child: SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "이용 약관",
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
          // 버그 제보 및 문의하기 (16pt)
          Padding(
            padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _launchUrl('https://www.instagram.com/fineplay.kr/');
                },
                child: SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "버그 제보 및 문의하기",
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
          // 로그아웃
          Padding(
            padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
            child: Center(
              child: GestureDetector(
                onTap: () => logoutDialog(context),
                child: SizedBox(
                  width: S.X_RATIO * 300,
                  child: Text(
                    "로그아웃",
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
      ),
    );
  }

  Widget buildSwitchRow(String label, bool value, String type) {
    return Padding(
      padding: EdgeInsets.only(top: 20 * S.Y_RATIO),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 30 * S.X_RATIO, right: 30 * S.X_RATIO),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Wanted sans',
                fontSize: 16 * S.Y_RATIO,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(right: 30 * S.X_RATIO),
            child: Transform.scale(
              scale: 0.8, // 텍스트 크기와 맞추기 위한 비율 (조정값을 실험적으로 변경)
              child: Switch(
                value: value,
                onChanged: (bool val) async {
                  final token = ref.read(tokenProvider);
                  ref.read(settingProvider.notifier).setAlarm(type, val);
                  await ref.read(settingProvider.notifier).updateAlarmSetting(
                      token, type, val);
                },
                activeColor: const Color(0xFFFF7E1D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logoutDialog(BuildContext context) async {
    S.init(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF21213D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: SizedBox(
            width: 300 * S.X_RATIO,
            height: 160 * S.Y_RATIO,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40 * S.Y_RATIO),
                Text("정말 로그아웃 할까요?",
                    style: TextStyle(color: Colors.white, fontSize: 16 * S.Y_RATIO,fontFamily: 'Wanted sans', )),
                SizedBox(height: 40 * S.Y_RATIO),
                const Divider(color: Colors.white, thickness: 1, height: 0),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false); // 취소
                        },
                        child: const Text("취소", style: TextStyle(color: Color(0xFF9E9E9E), fontFamily: 'Wanted sans',)),
                      ),
                    ),
                    Container(width: 1, height: 40 * S.Y_RATIO, color: Colors.white),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true); // 로그아웃
                        },
                        child: const Text("로그아웃", style: TextStyle(color: Colors.white, fontFamily: 'Wanted sans',)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // 다이얼로그가 닫힌 뒤, true인 경우만 처리
    if (shouldLogout == true) {
      ref.read(tokenProvider.notifier).state = '';
      ref.read(loginProvider.notifier).logout();
      ref.invalidate(settingProvider);
      ref.read(appRouterProvider).go('/');
    }
  }
}
