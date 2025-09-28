// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_result, library_private_types_in_public_api

import 'package:fineplay/presentation/view/feed_view/feed_view.dart';
import 'package:fineplay/presentation/viewmodel/home_provider.dart';
import 'package:fineplay/services/mypage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/presentation/view/home_view/main_home_view.dart';
import 'package:fineplay/presentation/view/mypage_view/mypage_view.dart';
import 'package:fineplay/presentation/view/team_view/team_view.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:fineplay/presentation/viewmodel/myteam_list_provider.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:tuple/tuple.dart';

import '../presentation/viewmodel/userId_provider.dart';
final selectedIndexProvider = StateProvider<int>((ref) => 2); // 초기값을 2로 설정

class NaviBar extends ConsumerStatefulWidget {
  const NaviBar({super.key, required this.title});

  final String title;

  @override
  _NaviBarState createState() => _NaviBarState();
}

class _NaviBarState extends ConsumerState<NaviBar> {

  static const List<Widget> _pages = <Widget>[
    Mypage_view(),
    Team_view(),
    Main_home_view(),
    FeedView()
  ];

  void _onItemTapped(int index) {
    ref.read(selectedIndexProvider.notifier).state = index;

    if (index == 0) {
      // 마이페이지 탭으로 돌아올 때마다 새로 로드
      final userId = ref.read(userIdProvider)!;
      final userToken = ref.read(tokenProvider);
      ref.refresh(mypageProvider(Tuple2(userId, userToken)));
    }

    if (index == 1) {
          ref.refresh(myTeamListProvider);
    }

    if (index == 2) {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        ref.invalidate(homeProvider(userId)); // ✅ 홈 새로고침

      }
    }
  }

  Future<bool?> _confirmLogout(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('아니오')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('예')),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // 🔧 앱 상태 정리(예시: 너의 프로바이더에 맞게 조정)
    ref.read(tokenProvider.notifier).state = '';
    ref.read(userIdProvider.notifier).state = null;

    if (mounted) context.go('/'); // 메인 로그인으로 이동
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    S.init(context);

    return PopScope(
        // 루트에서 브라우저/시스템 뒤로가기를 여기서 직접 처리
        canPop: false,
        onPopInvoked: (didPop) {
      if (didPop) return;


      // 2) 네비바 루트 탭 중 홈/마이/팀(0,1,2)에서만 로그아웃 확인 띄우기
      if (selectedIndex == 0 || selectedIndex == 1 || selectedIndex == 2 || selectedIndex == 3 ) {
        Future.microtask(() async {
          final ok = await _confirmLogout(context);
          if (ok == true) {
            await _logout(context, ref);
          }
        });
        return;
      }

      // 3) 그 외 탭(예: 피드)은 여기서 특별히 막지 않음
      //    필요하면 위 조건에 3도 포함하세요.
    },
    child:  Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF030319),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF030319),
              icon: Icon(
                Icons.account_circle_outlined,
                size: 22,
              ),
              label: '마이페이지',
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF030319),
              icon: Icon(
                Icons.groups_outlined,
                size: 22,
              ),
              label: '팀',
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF030319),
              icon: Icon(
                Icons.home_filled,
                size: 22,
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFF030319),
              icon: Icon(
                Icons.dynamic_feed,
                size: 22,
              ),
              label: '피드',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
          unselectedItemColor: const Color(0xFFBCBCBC),
          selectedItemColor: const Color(0xFF0A82FF),
          selectedIconTheme: const IconThemeData(size: 25),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            color: Color(0xFF0A82FF),
            fontSize: 13,
              fontFamily: 'Wanted sans'
          ),
          unselectedLabelStyle: const TextStyle(
            color: Color(0xFFBCBCBC),
            fontSize: 11,
              fontFamily: 'Wanted sans'
          ),
        ),
      ),
    ));
  }
}
