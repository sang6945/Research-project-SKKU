 import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// /// 새로운 알림이 왔는지 여부를 관리
 final newNotificationProvider = StateProvider<bool>((ref) => false);