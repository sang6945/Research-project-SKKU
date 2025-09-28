import 'package:fineplay/services/expiry_timer_service.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/router/app_router.dart';
import 'package:flutter_svg/svg.dart';

class DesktopLandingLayoutConfig {
  final double leftPanelW;
  final double rightPanelW;
  final double phoneWidth;
  final double phoneAspect;

  final double prefGutter;
  final double minGutter;
  final double prefSideMargin;
  final double minSideMargin;

  /// true = 오른쪽 유지(부족하면 왼쪽부터 숨김), false = 왼쪽 유지
  final bool keepRightPriority;

  /// 공간이 극도로 부족하면 폰 프레임 축소 허용 여부
  final bool allowPhoneScaleDown;
  final double minPhoneScale; // 0.8 = 80%까지 축소 허용

  final double leftLinger;   // 왼쪽 패널을 더 오래 보이게 (기본 64px)
  final double rightLinger;  // 오른쪽 패널 여유 (보통 0~16px)


  const DesktopLandingLayoutConfig({
    required this.leftPanelW,
    required this.rightPanelW,
    required this.phoneWidth,
    this.phoneAspect = 20.5 / 9.0,
    this.prefGutter = 32.0,
    this.minGutter = 16.0,
    this.prefSideMargin = 40.0,
    this.minSideMargin = 16.0,
    this.keepRightPriority = true,
    this.allowPhoneScaleDown = false,
    this.minPhoneScale = 0.9,
    this.leftLinger = 64.0,   // ★ 기본값
    this.rightLinger = 0.0,   // ★ 기본값
  });

  DesktopLandingLayoutConfig scaleBy(double xRatio) => DesktopLandingLayoutConfig(
    leftPanelW: leftPanelW * xRatio,
    rightPanelW: rightPanelW * xRatio,
    phoneWidth: phoneWidth * xRatio,
    phoneAspect: phoneAspect,
    prefGutter: prefGutter * xRatio,
    minGutter: minGutter * xRatio,
    prefSideMargin: prefSideMargin * xRatio,
    minSideMargin: minSideMargin * xRatio,
    keepRightPriority: keepRightPriority,
    allowPhoneScaleDown: allowPhoneScaleDown,
    minPhoneScale: minPhoneScale,
    leftLinger: leftLinger * xRatio,     // ★ 스케일
    rightLinger: rightLinger * xRatio,   // ★ 스케일
  );
}

/// 기본 프리셋(원하는 값으로만 조절하면 됨)
const _desktopLayoutBaseConfig = DesktopLandingLayoutConfig(
  leftPanelW: 650,   // 좌측 패널 폭
  rightPanelW: 450,  // 우측 패널 폭
  phoneWidth: 360,   // 중앙 폰 프레임 폭
  prefGutter: 32,
  minGutter: 16,
  prefSideMargin: 40,
  minSideMargin: 16,
  keepRightPriority: true,      // 오른쪽을 최대한 유지
  allowPhoneScaleDown: false,   // 필요시 true 로
  minPhoneScale: 0.9,
  leftLinger: 20.0,
  rightLinger: 300.0,

);

class _ResolvedLayout {
  final bool showLeft;
  final bool showRight;
  final double sideMargin;
  final double gutter;
  final double phoneScale; // 1.0 = 원본

  const _ResolvedLayout({
    required this.showLeft,
    required this.showRight,
    required this.sideMargin,
    required this.gutter,
    required this.phoneScale,
  });
}

_ResolvedLayout resolveDesktopLayout({
  required double availableWidth,
  required DesktopLandingLayoutConfig cfg,
}) {
  double sideMargin = cfg.prefSideMargin;
  double gutter = cfg.prefGutter;
  double phoneScale = 1.0;

  double remaining = availableWidth - (sideMargin * 2) - (cfg.phoneWidth * phoneScale);

  // ★ 좌우 모두 넣기 위한 요구 폭에서 linger 만큼 감산(=조금 겹칠 듯 말 듯 버팀)
  double needBoth = (cfg.leftPanelW + cfg.rightPanelW + gutter * 2)
      - (cfg.leftLinger + cfg.rightLinger);
  if (needBoth < 0) needBoth = 0;

  bool fitsBoth = remaining >= needBoth;

  // 선호 → 최소 여백 다운
  if (!fitsBoth) {
    sideMargin = cfg.minSideMargin;
    gutter = cfg.minGutter;
    remaining = availableWidth - (sideMargin * 2) - (cfg.phoneWidth * phoneScale);
    needBoth = (cfg.leftPanelW + cfg.rightPanelW + gutter * 2)
        - (cfg.leftLinger + cfg.rightLinger);
    if (needBoth < 0) needBoth = 0;
    fitsBoth = remaining >= needBoth;
  }

  // 폰 축소(허용 시)
  if (!fitsBoth && cfg.allowPhoneScaleDown) {
    final needForBoth = (cfg.leftPanelW + cfg.rightPanelW + gutter * 2)
        - (cfg.leftLinger + cfg.rightLinger);
    final clampedNeedForBoth = needForBoth < 0 ? 0 : needForBoth;

    final maxPhoneWidth = (availableWidth - (sideMargin * 2) - clampedNeedForBoth)
        .clamp(0.0, cfg.phoneWidth);
    final neededScale =
    (maxPhoneWidth / cfg.phoneWidth).clamp(cfg.minPhoneScale, 1.0);
    phoneScale = neededScale;

    remaining = availableWidth - (sideMargin * 2) - (cfg.phoneWidth * phoneScale);
    fitsBoth = remaining >= clampedNeedForBoth;
  }

  bool showLeft = true;
  bool showRight = true;

  if (!fitsBoth) {
    if (cfg.keepRightPriority) {
      // ★ 오른쪽 유지: 왼쪽을 숨길지 판단할 때도 왼쪽 linger를 고려해 더 오래 버팀
      final double needRightOnly = (cfg.rightPanelW + gutter) - cfg.leftLinger;
      final bool fitsRightOnly = remaining >= (needRightOnly < 0 ? 0 : needRightOnly);

      if (fitsRightOnly) {
        showLeft = false;
        showRight = true;
      } else {
        showLeft = false;
        showRight = false;
      }
    } else {
      // 왼쪽 유지: 오른쪽 숨김 판단에 rightLinger 적용(대칭)
      final double needLeftOnly = (cfg.leftPanelW + gutter) - cfg.rightLinger;
      final bool fitsLeftOnly = remaining >= (needLeftOnly < 0 ? 0 : needLeftOnly);

      if (fitsLeftOnly) {
        showLeft = true;
        showRight = false;
      } else {
        showLeft = false;
        showRight = false;
      }
    }
  } else {
    // 거의 딱 맞는 상황(타이트)에서도 왼쪽을 더 오래 남기고 싶으면 leftLinger만큼 여유를 줌
    final double tightThreshold = (cfg.leftPanelW + cfg.rightPanelW + gutter * 2)
        - (cfg.leftLinger + cfg.rightLinger) + 1;
    final bool barely = remaining < tightThreshold;

    if (barely) {
      if (cfg.keepRightPriority) {
        // 기본은 왼쪽을 끄지만, leftLinger가 크면 좀 더 버팀 → 이미 needBoth에 반영됨
        showLeft = false;
        showRight = true;
      } else {
        showLeft = true;
        showRight = false;
      }
    }
  }

  return _ResolvedLayout(
    showLeft: showLeft,
    showRight: showRight,
    sideMargin: sideMargin,
    gutter: gutter,
    phoneScale: phoneScale,
  );
}



final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
void main() {
  runApp(
    // 전역 Provider 컨테이너를 생성합니다.
    const ProviderScope(
      child: MyApp(),
    ),
  );

}
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 화면 비율 계산
    S.init(context);
    final router = ref.watch(appRouterProvider);

    ref.watch(expiryTimerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff000014),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF21213F),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 14 * S.Y_RATIO,
            fontFamily: 'Wanted sans',
            fontWeight: FontWeight.w500,
          ),
          actionTextColor: const Color(0xFFFF7E1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * S.X_RATIO),
          ),
          behavior: SnackBarBehavior.fixed,
        ),
      ),
      themeMode: ThemeMode.dark,

      // ★ 여기 builder를 추가하세요
      // ★ 여기 builder를 교체하세요
      builder: (context, child) {
        S.init(context);

        if (!S.isDesktopMode) return child!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;

            // 1) 화면 비율에 맞춰 프리셋 스케일링
            final cfg = _desktopLayoutBaseConfig.scaleBy(S.X_RATIO);

            // 2) 가시성/여백/폰 스케일 결정
            final r = resolveDesktopLayout(
              availableWidth: w,
              cfg: cfg,
            );

            final phoneW = cfg.phoneWidth * r.phoneScale;
            final phoneH = phoneW * cfg.phoneAspect;

            return Stack(
              children: [
                // 배경 + 좌/우 패널
                Positioned.fill(
                  child: Container(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: r.sideMargin),
                    child: SafeArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 좌측 패널
                          Offstage(
                            offstage: !r.showLeft,
                            child: SizedBox(
                              width: cfg.leftPanelW,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                ],
                              ),
                            ),
                          ),

                          // 좌측 패널과 폰 사이 여백
                          SizedBox(width: r.showLeft ? r.gutter : 0),

                          // 중앙 공간 (폰은 Stack의 다음 위젯)
                          const Expanded(child: SizedBox()),

                          // 폰과 우측 패널 사이 여백
                          SizedBox(width: r.showRight ? r.gutter : 0),

                          // 우측 패널

                        ],
                      ),
                    ),
                  ),
                ),

                // 중앙 폰 프레임
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: phoneW,
                    height: phoneH.clamp(0.0, h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF030319),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 60,
                          spreadRadius: 0,
                          offset: Offset(0, 12),
                          color: Color(0x1A000000),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
      },

      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
