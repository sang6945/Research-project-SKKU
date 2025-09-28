// ignore_for_file: camel_case_types

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
  import 'package:fineplay/services/mypage_service.dart';
import 'package:fineplay/presentation/viewmodel/new_notification_provider.dart';
import 'package:tuple/tuple.dart';

class Statpage_view extends ConsumerStatefulWidget {
  final String feature;
  final int userId;
  final String userToken;

  const Statpage_view({
    super.key,
    required this.feature,
    required this.userId,
    required this.userToken,
  });

  @override
  ConsumerState<Statpage_view> createState() => _StatpageViewState();
}

class _StatpageViewState extends ConsumerState<Statpage_view>{

  @override
  void initState() {
    super.initState();
    // ▶ 들어갈 때마다 movepageProvider 캐시 무효화
    Future.microtask(() {
      ref.invalidate(pageMoveProvider(Tuple3(
        widget.feature,
        widget.userId,
        widget.userToken,
      )));
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    // 1) SSE로부터 온 새 알림 여부
    // 2) SSE로부터 온 새 알림 여부
     final bool hasNewSse = ref.watch(newNotificationProvider);
    // 3) movepage API 로부터 내려준 읽지 않은 알림 여부 ← HERE
    final pageMoveAsync = ref.watch(pageMoveProvider(Tuple3(widget.feature, widget.userId, widget.userToken)));
    final bool hasNewFromMove = pageMoveAsync.asData?.value.hasUnreadNotification ?? false;

    // 4) 둘 중 하나라도 true 면 빨간 아이콘 ← HERE
    final bool showRedIcon = hasNewSse || hasNewFromMove;


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70 * S.Y_RATIO,
        title: Padding(
          padding: EdgeInsets.only(top: 25 * S.Y_RATIO, left: 10 * S.X_RATIO),
          child: Text(
            "Fine Play",
            style: TextStyle(
              fontSize: 15 * S.Y_RATIO,
              fontFamily: 'GiantsInline',
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF7E1D),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF030319),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 25 * S.Y_RATIO),
            child: IconButton(

              icon: showRedIcon
              // newNotification == true → 빨간 알림 아이콘
                  ? SvgPicture.asset(
                'assets/ban/notification_red.svg',
                width: 23 * S.Y_RATIO,
                height: 23 * S.Y_RATIO,
              )
              // false → 기본 아이콘
                  : SvgPicture.asset(
                'assets/ban/notification.svg',
                width: 23 * S.Y_RATIO,
                height: 23 * S.Y_RATIO,
              ),
              onPressed: () {
                 ref.read(newNotificationProvider.notifier).state = false;
                 context.push("/notification");
              },
            ),
          ),
          Padding(
            padding:
            EdgeInsets.only(top: 25 * S.Y_RATIO, right: 30 * S.X_RATIO),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                size: 23 * S.Y_RATIO,
                color: Colors.white,
              ),
              onPressed: () {
                context.push('/setting');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BacktoMypage(feature: widget.feature),
            StatContent(
                feature: widget.feature,
                userId: widget.userId,
                userToken: widget.userToken), // ✅ 백엔드 연결
          ],
        ),
      ),
      backgroundColor: const Color(0xFF030319),
    );
  }
}

class BacktoMypage extends StatelessWidget {
  final String feature; // feature 값 받기

  const BacktoMypage({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: S.X_RATIO * 35),
      margin: EdgeInsets.only(top: S.Y_RATIO * 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // 이전 페이지로 이동
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios, // 뒤로가기 아이콘
              size: 24 * S.Y_RATIO,
              color: Colors.white,
            ),
          ),
          Text(
            feature,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20 * S.Y_RATIO, // 텍스트 크기 설정
              fontWeight: FontWeight.w700,
                fontFamily: 'Wanted sans'
            ),
          ),
        ],
      ),
    );
  }
}

class StatContent extends ConsumerStatefulWidget {
  final String feature;
  final int userId;
  final String userToken;

  const StatContent({
    super.key,
    required this.feature,
    required this.userId,
    required this.userToken,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StatContentState createState() => _StatContentState();
}

class _StatContentState extends ConsumerState<StatContent> {
  String? imgPath;
  bool isLoading = true;
  late MypageService mypageService; // ✅ MypageService 인스턴스 추가

  static const Map<String, String> _placeholderAssets = {
    "SHO": "assets/ban/sho.png",
    "SPD": "assets/ban/spd.png",
    "PAS": "assets/ban/pas.png",
    "PAC": "assets/ban/pac.png",
    "DRV": "assets/ban/drv.png",
    "DEC": "assets/ban/dec.png",
    "DRI": "assets/ban/dri.png",
    "TAC": "assets/ban/tac.png",
    "BLD": "assets/ban/bld.png",
  };

  @override
  void initState() {
    super.initState();
    mypageService =
        MypageService(authToken: widget.userToken); // ✅ MypageService 초기화
    _fetchStatImage();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchStatImage();
  }


  Future<void> _fetchStatImage() async {
    try {
      // movePage가 PageMoveResult 를 반환 ← HERE
      final result = await mypageService.movePage(widget.feature, widget.userId);
      // movepage에서 읽은 unread 알림이 있으면 SSE provider에도 반영
      if (result.hasUnreadNotification) {
         ref.read(newNotificationProvider.notifier).state = true;
      }
      setState(() {
        imgPath = result.img;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        imgPath = null;
        isLoading = false;
      });
      if (kDebugMode) {
        print("스탯 페이지 이동 실패: $e");
      }
    }
  }

  String get _defaultAsset {
    return _placeholderAssets[widget.feature] ??
        _placeholderAssets.values.first;
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(
          top: 16 * S.Y_RATIO, left: 30 * S.X_RATIO, right: 30 * S.X_RATIO),
      width: 300 * S.X_RATIO,
      height: 570 * S.Y_RATIO,
      //padding: EdgeInsets.all(8.0), //이미지 비율마다 패딩 다르게 적용됨-> 기존 컨테이너 안에 패딩주고원하는크기의 컨테이너 만들고 거기에 사진 꽉 채우기
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: imgPath != null
            ?Colors.transparent:const Color(0xff21213d),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator() // ✅ 로딩 중이면 로딩 표시
            : imgPath != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            imgPath!,
            //width: double.infinity, // 가로를 꽉 채움
            //height: double.infinity, // 세로도 꽉 채움
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                  child: Text("이미지 로드 실패$imgPath",
                      style: const TextStyle(color: Colors.white)));
            },
          ),
        )

            : ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            _defaultAsset,
            fit: BoxFit.cover,
          ),
        ),

      ),
    );
  }
}
