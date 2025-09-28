import 'package:flutter/material.dart';
import '/../services/notice_service.dart';
import 'package:fineplay/utils/screen_ratio.dart';


class NoticeDetailView extends StatelessWidget {
  final int id;
  final String token;

  const NoticeDetailView({
    super.key,
    required this.id,
    required this.token,
  });

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
  Widget build(BuildContext context) {
    S.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF030319),
      appBar:AppBar(
        // 좌측 상단 뒤로가기 버튼 추가
        leading: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
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
      body: SingleChildScrollView( // 전체 내용 스크롤 가능하게 만듦
        padding: EdgeInsets.only(top:30*S.Y_RATIO,left:20*S.X_RATIO), // Padding 적용
        child: FutureBuilder<Notice>(
          future: fetchNoticeById(id, token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('에러: ${snapshot.error}'));
            } else {
              final notice = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white,  fontFamily: 'Wanted Sans',),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '작성일: ${formatKST(notice.createdAt)}',
                      style: const TextStyle(color: Colors.white,  fontFamily: 'Wanted Sans',),
                    ),
                    const Divider(height: 20),
                    Text(
                      notice.content,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white,  fontFamily: 'Wanted Sans',), // 본문 텍스트 스타일링
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}