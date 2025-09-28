import 'package:flutter/material.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:go_router/go_router.dart';

PreferredSizeWidget buildCustomAppBar(BuildContext context, {required String title, bool showSettings = true}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(70 * S.Y_RATIO),
    child: AppBar(
      title: Padding(
        padding: EdgeInsets.only(top: 1 * S.Y_RATIO, left: 1 * S.X_RATIO),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20 * S.Y_RATIO,
            fontFamily: 'GiantsInline',
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFF7E1D),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF030319),
      actions: showSettings
          ? [
        Padding(
          padding: EdgeInsets.only(top: 1 * S.Y_RATIO),
          child: IconButton(
            icon: Icon(Icons.notifications_none_outlined, size: 23 * S.Y_RATIO),
            onPressed: () {
              context.push("/notification");
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 1 * S.Y_RATIO, right: 10 * S.X_RATIO),
          child: IconButton(
            icon: Icon(Icons.settings, size: 23 * S.Y_RATIO),
            onPressed: () {
              context.push(
                '/setting',
                extra: {},
              );
            },
          ),
        ),
      ]
          : null,
    ),
  );
}
