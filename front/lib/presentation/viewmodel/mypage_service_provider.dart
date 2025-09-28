// viewmodel/mypage_service_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/services/mypage_service.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';

/// 토큰을 읽어서 MypageService 인스턴스를 제공하는 Provider
final mypageServiceProvider = Provider<MypageService>((ref) {
  final token = ref.watch(tokenProvider);
  return MypageService(authToken: token);
});
