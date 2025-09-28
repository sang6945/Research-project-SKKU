import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/../services/notice_service.dart';
import '../../viewmodel/token_provider.dart';



import 'dart:async';
import 'package:fineplay/utils/screen_ratio.dart';




class NoticeListView extends ConsumerStatefulWidget {
  const NoticeListView({super.key});

  @override
  ConsumerState<NoticeListView> createState() => _NoticeListViewState();
}

class _NoticeListViewState extends ConsumerState<NoticeListView> {
  late Future<List<Notice>> futureNotices;

  String formatKST(String isoish) {
    if (isoish.isEmpty) return "-";

    DateTime dt = DateTime.parse(isoish);

    // Z 또는 타임존 표기가 없으면: 그냥 그대로 출력
    final hasTZ = RegExp(r'[zZ]|[+\-]\d{2}:\d{2}$').hasMatch(isoish);

    if (!hasTZ) {
      // 그냥 로컬 시간 문자열로 취급
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

    // 타임존(Z) 붙어있으면 → UTC로 간주하고 +9h
    DateTime kst = dt.add(const Duration(hours: 9));
    return "${kst.year}-${kst.month.toString().padLeft(2, '0')}-${kst.day.toString().padLeft(2, '0')} "
        "${kst.hour.toString().padLeft(2, '0')}:${kst.minute.toString().padLeft(2, '0')}";
  }


  @override
  void initState() {
    super.initState();
    final token = ref.read(tokenProvider);
    futureNotices = fetchNotices(token);
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF030319),
        appBar:AppBar(
          // 좌측 상단 뒤로가기 버튼 추가
          leading: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 32.0 * S.Y_RATIO,
                  left: 39.0 * S.X_RATIO,
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24.0 * S.Y_RATIO,
                ),
              ),
            ),
          ),

          title: Center(  // 먼저 Center로 정렬
            child: Padding(  // Padding 위젯을 사용해 이동
              padding: EdgeInsets.only(right: 39.0* S.X_RATIO, top:32.0*S.Y_RATIO),  // 좌우 패딩 조정
              child: const Text(
                "공지사항",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFF030319),
          actions: const [], // 상단 아이콘 제거
        ),
      body:SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 30 * S.Y_RATIO, left: 20 * S.X_RATIO),
          child: FutureBuilder<List<Notice>>(
            future: futureNotices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('에러: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('공지사항이 없습니다.'));
              } else {
                final notices = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true, // ListView 크기를 부모 위젯에 맞게 축소
                  physics: const NeverScrollableScrollPhysics(), // ListView 내에서 스크롤을 비활성화
                  itemCount: notices.length,
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    return ListTile(
                      title: Text(notice.title),
                      subtitle: Text(formatKST(notice.createdAt)),
                      onTap: () {
                        context.push("/noticedetail",
                        extra: {'id': notice.id,
                            'token': ref.read(tokenProvider),});
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      )



    );
  }
}
