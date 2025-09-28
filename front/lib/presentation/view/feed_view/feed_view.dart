import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter/material.dart';


class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return
      Container(
        child: Center(child: Text("추후 업데이트 예정입니다.",
        style: TextStyle( color: Colors.white,
          fontSize: 16 * S.Y_RATIO, fontFamily: 'Wanted sans',),)),
      );
  }
}
