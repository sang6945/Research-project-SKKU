// lib/presentation/view/home_view/favorite_box.dart

import 'dart:convert';
import 'package:fineplay/presentation/viewmodel/user_favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_svg/svg.dart';
import '../../viewmodel/token_provider.dart';
import '../../viewmodel/userId_provider.dart';
import '../../viewmodel/favorite_user_list_provider.dart';

class FavoriteBox extends ConsumerStatefulWidget {
  final FavoriteUser user;
  const FavoriteBox({super.key, required this.user});

  @override
  ConsumerState<FavoriteBox> createState() => _FavoriteBoxState();
}

class _FavoriteBoxState extends ConsumerState<FavoriteBox> {
  final bool _isStarred = true;

  /// DELETE 요청을 body와 함께 보내려면 http.Request 사용
  Future<void> _unfavorite() async {
    final token  = ref.read(tokenProvider);
    final userId = ref.read(userIdProvider)!;
    final favId  = widget.user.userId;

    final uri = Uri.parse('http://localhost:8080/api/favorite/user/delete');
    final request = http.Request('DELETE', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'userId': userId,
        'favoriteUserId': favId,
      });

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200) {
      // 성공하면 프로바이더를 리셋해서 리스트에서 사라지도록
      ref.invalidate(favoriteUserListProvider);
      ref.invalidate(isUserFavoriteProvider(widget.user.userId));
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('해제 실패: ${resp.body}')),
      );
    }
  }

  void _onStarPressed() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF21213D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SizedBox(
          width: 300 * S.X_RATIO,
          height: 170 * S.Y_RATIO,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 35 * S.Y_RATIO),
              Text("즐겨찾기를",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * S.Y_RATIO, fontFamily: 'Wanted sans',
                  )),
              Text("해제하시겠어요?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * S.Y_RATIO,
                    fontFamily: 'Wanted sans',
                  )),
              SizedBox(height: 40 * S.Y_RATIO),
              const Divider(color: Colors.white, thickness: 1, height: 0),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("취소",
                          style: TextStyle(color: Color(0xFF9E9E9E),  fontFamily: 'Wanted sans',)),
                    ),
                  ),
                  Container(
                      width: 1, height: 40 * S.Y_RATIO, color: Colors.white),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _unfavorite(); // _unfavorite 호출하여 실제 해제
                      },
                      child: const Text("확인",
                          style: TextStyle(color: Colors.white, fontFamily: 'Wanted sans',), ),
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


  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return Center(
      child: Container(
        height: S.Y_RATIO * 60,
        width: S.X_RATIO * 300,
        margin: EdgeInsets.only(bottom: 10 * S.Y_RATIO),
        decoration: BoxDecoration(
          color: const Color(0xFF21213d),
          borderRadius: BorderRadius.circular(10.0 * S.Y_RATIO),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              children: [
                SizedBox(width: 20 * S.X_RATIO),
                SizedBox(
                    width: 40*S.Y_RATIO,
                    height: 40*S.Y_RATIO,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(300.0),
                      child: SvgPicture.asset(
                        'assets/ban/userprofile.svg',
                        fit: BoxFit.cover,
                      ),)
                ),
                SizedBox(width: 11 * S.X_RATIO),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.nickName,
                      style: TextStyle(
                        fontSize: 18 * S.Y_RATIO,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Wanted sans',
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${u.position.toUpperCase()} / ${u.ovr}',
                      style: TextStyle(
                        fontSize: 12 * S.Y_RATIO,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Wanted sans',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ★ 즐겨찾기 해제 버튼
            Positioned(
              right: 10 * S.X_RATIO,
              child: IconButton(
                icon: Icon(
                  _isStarred ? Icons.star : Icons.star_border_outlined,
                  size: 25 * S.Y_RATIO,
                  color: const Color(0xFF0A82FF),
                ),
                onPressed: _onStarPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
