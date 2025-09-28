// ignore_for_file: camel_case_types

import 'package:fineplay/presentation/view/team_view/game_result_view.dart';
import 'package:fineplay/presentation/viewmodel/new_notification_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter/cupertino.dart';

import 'package:fineplay/services/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:tuple/tuple.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';

class Notification_view extends ConsumerStatefulWidget {
  const Notification_view({super.key});

  @override
  ConsumerState<Notification_view> createState() => _NotificationViewState();
}


class _NotificationViewState extends ConsumerState<Notification_view> {
  late final int currentUserId;
  late final String authToken;

  @override
  void initState() {
    super.initState();
    // ← HERE: 화면 진입 시마다 캐시 무효화
    currentUserId = ref.read(userIdProvider)!;
    authToken     = ref.read(tokenProvider);
    Future.microtask(() {
      ref.invalidate(notificationListProvider(Tuple2(currentUserId, authToken)));
    });
  }

  void _onNotificationTap(NotificationResponseDto n) {
    if(n.type == 'NOTICE'){

    }
    else if(n.type == 'TEAM_REQUEST'){

      context.pushNamed("managerequest",
          pathParameters: {'teamId': n.teamId!.toString()});
    }
    else if (n.type == 'REQUEST_RESULT') {
      // 팀 가입 처리 결과 알림 → 해당 팀으로
      context.pushNamed(
        'searchedteam',

        pathParameters: {'teamId': n.teamId!.toString()},
      );
    }
    else if (n.type == 'MATCH_REGISTER') {

      context.pushNamed("gameresult",

        pathParameters: {"userId": currentUserId.toString(),"teamId": n.teamId!.toString(),"game_num":n.matchId!.toString(),"userToken": authToken,},
      );
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => Game_result_view(userId: currentUserId,teamId: n.teamId!,game_num:n.matchId!,userToken: authToken,),
        ),
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    final notifAsync = ref.watch(notificationListProvider(Tuple2(currentUserId, authToken)));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // ignore: unused_result
            ref.refresh(newNotificationProvider);
            Navigator.pop(context);},
        ),
        title: Text("알림", style: TextStyle(fontSize: 18 * S.Y_RATIO)),
        backgroundColor: const Color(0xFF030319),
      ),
      body: notifAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (err, _) => Center(child: Text("알림 조회 실패: $err", style: const TextStyle(color: Colors.white))),
        data:    (list) {
          if (list.isEmpty) {
            return Center(
              child: Text("알림이 없어요", style: TextStyle(color: Colors.white, fontSize: 16 * S.Y_RATIO)),
            );
          }

          // ← HERE: 서버에서 받은 리스트를 createdAt 내림차순으로 정렬
          final sorted = [...list]
            ..sort((a, b) {
              final da = DateTime.parse(a.createdAt);
              final db = DateTime.parse(b.createdAt);
              return db.compareTo(da); // db - da: 내림차순
            });

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 28 * S.Y_RATIO),
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(height: 10 * S.Y_RATIO),
            itemBuilder: (context, i) {
              final n = sorted[i];
              return  Center(
                child: GestureDetector(
                  onTap: () => _onNotificationTap(n),  // ← HERE: 타입별 이동
                  child: NotifiBox1(
                    notification: n,
                    onDelete: () async {
                      try {
                        await ref.read(notificationServiceProvider).deleteNotification(n.id);
                        ref.invalidate(notificationListProvider(Tuple2(currentUserId, authToken)));
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('삭제 실패: $e')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ← HERE: Widget은 Stateless로 변경, NotificationResponseDto 사용
class NotifiBox1 extends StatelessWidget {
  final NotificationResponseDto notification;
  final VoidCallback            onDelete;

  const NotifiBox1({
    super.key,
    required this.notification,
    required this.onDelete,
  });



  // ← HERE: createdAt(String) → DateTime 파싱 후 “몇 분 전” 포맷
  String timeAgo(String createdAt) {
    final dt = DateTime.parse(createdAt).add(const Duration(hours: 9));
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours   < 1) return '${diff.inMinutes}분 전';
    if (kDebugMode) {
      print(diff);
    }
    if (kDebugMode) {
      print(DateTime.now());
    }
    if (kDebugMode) {
      print(dt);
    }
    if (kDebugMode) {
      print(createdAt);
    }

    return '${diff.inHours}시간 전';
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      height: S.Y_RATIO * 100,
      width:  S.X_RATIO * 300,
      decoration: BoxDecoration(
        color:           const Color(0xFF21213d),
        borderRadius:   BorderRadius.circular(15.0),
      ),
      child: Stack(
        children: [
          // ← 새 알림일 때만 표시할 빨간 점
          if (notification.status == 'new')
            Positioned(
              top: 10 * S.Y_RATIO,
              left: 10 * S.X_RATIO,
              child: Container(
                width: 6 * S.Y_RATIO,
                height: 6 * S.Y_RATIO,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.only(left: 18 * S.X_RATIO, top: 25 * S.Y_RATIO),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    color:      const Color(0xFFC6C6C6),
                    fontSize:   14 * S.Y_RATIO,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Wanted sans',
                    height:     1.0,
                  ),
                ),
                SizedBox(height: 12 * S.Y_RATIO),
                Text(
                  notification.content,
                  style: TextStyle(
                    color:      Colors.white,
                    fontSize:   14 * S.Y_RATIO,
                    fontFamily: 'Wanted Sans',
                    fontWeight: FontWeight.w500,
                    height:     1.0,
                  ),
                ),
              ],
            ),
          ),

          // 삭제 버튼
          Positioned(
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close, size: 20 * S.Y_RATIO, color: const Color(0xFFB5B5B5)),
              onPressed: onDelete,
            ),
          ),

          // 시간 표시
          Positioned(
            right: 16 * S.X_RATIO,
            bottom: 12 * S.Y_RATIO,
            child: Text(
              timeAgo(notification.createdAt),
              style: TextStyle(
                color:      const Color(0xFFB5B5B5),
                fontSize:   12 * S.Y_RATIO,
                fontWeight: FontWeight.w400,
                fontFamily: 'Wanted sans',
                height:     1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}