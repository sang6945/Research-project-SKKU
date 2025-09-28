// lib/presentation/view/home_view/favorite_user_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/favorite_user_list_provider.dart';  // ✔️ import 변경
import 'favorite_box.dart';                               // ✔️ FavoriteBox 위젯
import 'main_home_view.dart' show routeObserver;
// ignore: camel_case_types
class Favorite_User_view extends ConsumerStatefulWidget {
  const Favorite_User_view({super.key});
  @override
  ConsumerState<Favorite_User_view> createState() => _FavoriteUserViewState();
}

class _FavoriteUserViewState extends ConsumerState<Favorite_User_view> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// 즐겨찾기 편집(추가/삭제) 화면에서 돌아올 때마다 목록 갱신
  @override
  void didPopNext() {
    ref.invalidate(favoriteUserListProvider);
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    // 1) 즐겨찾기 리스트를 구독
    final favAsync = ref.watch(favoriteUserListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text("즐겨찾는 플레이어", style: TextStyle(fontSize: 18 * S.Y_RATIO,
          fontFamily: 'Wanted sans',
        )),
        backgroundColor: const Color(0xFF030319),
      ),
      body: favAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('오류 발생: $e',
            style: const TextStyle(color: Colors.white,  fontFamily: 'Wanted sans',),
          ),
        ),
        data: (users) {
          // 2) 리스트가 비어있으면 안내 문구
          if (users.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100 * S.Y_RATIO),
                child: Text(
                  "즐겨찾는 플레이어를 추가해주세요!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * S.Y_RATIO,
                    fontFamily: 'Wanted sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }
          // 3) 데이터가 있으면 동적 렌더링
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 28 * S.Y_RATIO),
            child: Column(
              children: users
              // 여기를 한 줄로 바꿔주세요 ↓
                  .map((u) => FavoriteBox(user: u))
                  .toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 90 * S.Y_RATIO,
        padding: EdgeInsets.symmetric(horizontal: 20 * S.X_RATIO),
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              minimumSize: Size(300 * S.X_RATIO, 45 * S.Y_RATIO),
            ),
            onPressed: () {
             context.push("/findinguser");
            },
            child: Text(
              "즐겨찾는 플레이어 추가하기",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * S.Y_RATIO,
                fontFamily: 'Wanted sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF030319),
    );
  }
}
