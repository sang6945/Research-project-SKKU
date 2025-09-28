// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'package:flutter/material.dart';

class S {
  static double _xRatio = 1.0;
  static double _yRatio = 1.0;

  // 스마트폰 기준 해상도 비율(360×800)과 허용 오차(±0.15)
  static const double _smartphoneAspect = 360 / 800;
  static const double _tolerance = 0.15;

  /// 데스크탑(=비율 고정) 모드인지 여부
  static bool get isDesktopMode => (_xRatio == _yRatio);

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final aspect = w / h;

    if ((aspect - _smartphoneAspect).abs() > _tolerance) {
      // 데스크탑·태블릿 → 균일 스케일
      final scale = min(w / 360.0, h / 800.0);
      _xRatio = scale;
      _yRatio = scale;
    } else {
      // 스마트폰 범위 내 → 축별 스케일
      _xRatio = w / 360.0;
      _yRatio = h / 800.0;
    }
  }

  /// X, Y 비율
  static double get X_RATIO => _xRatio;
  static double get Y_RATIO => _yRatio;

  /// 데스크탑 모드일 때 child를 Center 로 감싸고, 아니면 그냥 반환
  static Widget wrapWithCenter({required Widget child}) {
    return isDesktopMode
        ? Center(child: child)
        : child;
  }
}
