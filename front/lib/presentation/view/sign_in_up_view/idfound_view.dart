// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/router/app_router.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/findid_provider.dart';

class Idfound_view extends ConsumerWidget {
  const Idfound_view({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    return PopScope(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              const Completedsend_ban(),
              const Checkicon_ban(),
              const Sendmessage_ban(),
              Tologin_ban(ref),
              Torepassword_ban(ref)
            ],
          ),
        ),
      ),
    );
  }
}

class Tologin_ban extends ConsumerWidget {
  const Tologin_ban(this.ref, {super.key});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    return GestureDetector(
      onTap: () => ref.read(appRouterProvider).go('/'),
      child: Container(
        padding: EdgeInsets.only(top: S.Y_RATIO * 602),
        alignment: Alignment.center,
        child: SvgPicture.asset('assets/ban/tologin_ban.svg'),
      ),
    );
  }
}

class Torepassword_ban extends ConsumerWidget {
  const Torepassword_ban(this.ref, {super.key});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    return GestureDetector(
      onTap: () => context.go('/repassword'),
      child: Container(
        padding: EdgeInsets.only(top: S.Y_RATIO * 656),
        alignment: Alignment.center,
        child: SvgPicture.asset('assets/ban/torepassword_ban.svg'),
      ),
    );
  }
}


class Checkicon_ban extends StatelessWidget {
  const Checkicon_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      padding: EdgeInsets.only(
        top: S.Y_RATIO * 245,
      ),
      alignment: Alignment.topCenter,
      child: SvgPicture.asset(
        'assets/ban/Checkicon_ban.svg',
      ),
    );
  }
}


class Completedsend_ban extends StatelessWidget {
  const Completedsend_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
        padding: EdgeInsets.only(top: S.Y_RATIO * 100),
        alignment: Alignment.topCenter,
        child: const Text(
          '아이디 찾기 완료 ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Wanted Sans',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ));
  }
}

class Sendmessage_ban extends ConsumerWidget {
  const Sendmessage_ban({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    final findIdState = ref.watch(findIdProvider);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: S.Y_RATIO * 390),
          alignment: Alignment.center,
          child: Column(
            children: [
              const Text(
                '입력하신 정보로 조회된 아이디는',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              Text(
                '${findIdState.foundId} 입니다!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w800,
                  height: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


