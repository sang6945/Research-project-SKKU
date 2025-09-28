// import 'package:flutter/material.dart';
// import 'package:flutter_client_sse/flutter_client_sse.dart';
// import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fineplay/presentation/viewmodel/token_provider.dart';
// import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
// import 'package:fineplay/presentation/viewmodel/new_notification_provider.dart';  // 추가
//
//
// class SseNotifier extends StateNotifier<bool> {
//   final Ref ref;
//   SseNotifier(this.ref) : super(false);
//
//   /// 로그인 후 SSE 연결 시작
//   Future<void> startSseConnection(String userId, String token) async {
//     if (token.isEmpty) {
//       print('토큰이 없습니다. SSE 연결을 시도할 수 없습니다.');
//       return;
//     }
//     print('연결 시도');
//     try {
//       final url = 'http://localhost:8080/sse/subscribe?userId=$userId';
//
//       // header → headers 로 수정
//       final eventSource = SSEClient.subscribeToSSE(
//         method: SSERequestType.GET,
//         url: url,
//         header: <String, String>{
//           'Authorization': 'Bearer $token',
//           'Accept': 'text/event-stream',
//           'Cache-Control': 'no-cache',
//         },
//       );
//
//       // 연결이 성공적으로 설정되었을 때
//       print('연결 성공');
//       state = true;
//
//       // 스트림 수신 처리
//       eventSource.listen(
//             (event) {
//           // event.event: "notification"
//           // event.id: 서버에서 보내준 Notification.id
//           // event.data: JSON 으로 직렬화된 Notification 객체
//           debugPrint('SSE onEvent: ${event.event}');
//           debugPrint('SSE id: ${event.id}');
//           debugPrint('SSE data: ${event.data}');
//           // TODO: 여기에 실제 UI 업데이트나 상태 반영 로직 추가
//
//           print('알림옴!');
//           // 새 알림 이벤트가 오면 newNotificationProvider를 true로!
//           // ref.read(newNotificationProvider.notifier).state = true;
//         },
//         onError: (err) {
//           print('SSE 에러: $err');
//           state = false;
//         },
//         onDone: () {
//           print('SSE 닫힘');
//           state = false;
//         },
//       );
//     } catch (e) {
//       print('SSE 연결 실패: $e');
//       state = false;
//     }
//   }
// }
//
// final sseProvider = StateNotifierProvider<SseNotifier, bool>((ref) {
//   return SseNotifier(ref);
// });
// //