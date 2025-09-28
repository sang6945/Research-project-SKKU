// expiry_timer_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/router/app_router.dart';

final expiryTimerProvider = Provider<ExpiryTimerService>((ref) {
  return ExpiryTimerService(ref);
});

class ExpiryTimerService {
  final Ref _ref;  // Reader 대신 Ref
  final _storage = const FlutterSecureStorage();
  Timer? _timer;

  ExpiryTimerService(this._ref) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // 30초마다 토큰 만료 체크
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkExpiry();
    });
  }

  Future<void> _checkExpiry() async {
    final expStr = await _storage.read(key: 'tokenExp');
    if (expStr == null) return;

    final expSec = int.tryParse(expStr);
    if (expSec == null) return;

    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (nowSec >= expSec) {
      if (kDebugMode) {
        print("⏱ Timer check: Token expired, logging out.");
      }
      await _logout();
    } else {
      if (kDebugMode) {
        print("⏱ Timer check: Token still valid (exp=$expSec, now=$nowSec)");
      }
    }
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    final router = _ref.read(appRouterProvider); // ref.read 사용
    router.go(AppRoutes.mainLogin);
  }

  void dispose() {
    _timer?.cancel();
  }
}
