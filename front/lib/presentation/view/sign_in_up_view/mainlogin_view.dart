// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/presentation/viewmodel/login_provider.dart';

class mainlogin_view extends ConsumerWidget {
  const mainlogin_view({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              const FinePlayLogo_ban(),
              const Writeid(),
              const Writepw(),
              // CircleCheck(),
              // Maintainlogin(),
              if (loginState.isLoading)
                const Center(child: CircularProgressIndicator()), // 로딩 표시
              if (loginState.errorMessage.isNotEmpty)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      loginState.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              const LoginButton(),
              const RegisterButton(),
              const FindIdPwButton(),
              // OrLines(),
              // ImageButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class FinePlayLogo_ban extends StatelessWidget {
  const FinePlayLogo_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      padding: EdgeInsets.only(top: 180 * S.Y_RATIO,),

      child: Column(
        children: [
          Center(
            child: Text(
              'My BaseBall',
              style: TextStyle(
                color: const Color(0xFF0A82FF),
                fontSize: 40*S.Y_RATIO,
                fontFamily: 'GiantsInline',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class Writeid extends ConsumerWidget {
  const Writeid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    return Stack(
      children: [
        Container(
            padding:  EdgeInsets.only(top: S.Y_RATIO * 368, left: S.X_RATIO * 30),

            child: Container(
              height: S.Y_RATIO * 44,
              width: S.X_RATIO * 300,
              decoration: BoxDecoration(
                color: const Color(0xFF21213d),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Stack(
                  children: [
                    Positioned.fill(
                      child: TextField(
                        onChanged: (value) {
                          ref.read(loginProvider.notifier).updateEmail(value);
                        },
                        style: TextStyle(color: Colors.white,
                            fontFamily: 'Wanted sans'
                            ,fontSize: 15*S.Y_RATIO)
                        ,
                        decoration: InputDecoration(
                          hintText: '이메일 주소 입력',
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Wanted sans',

                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: S.X_RATIO * 20, bottom: S.Y_RATIO * 12),
                        ),

                      ),


                    ),
                  ]
              ),
            )
        )
      ],
    );
  }
}

class Writepw extends ConsumerWidget {
  const Writepw({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: S.Y_RATIO * 422,
            left: S.X_RATIO * 30,
          ),
          child: Container(
            height: S.Y_RATIO * 44,
            width: S.X_RATIO * 300,
            decoration: BoxDecoration(
              color: const Color(0xFF21213d),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              obscureText: true,
              textInputAction: TextInputAction.done,        // ← 엔터 동작을 ‘완료’로
              onChanged: (value) {
                ref.read(loginProvider.notifier).updatePassword(value);
              },
              onSubmitted: (_) async {                       // ← Enter 키 누르면 로그인 호출
                await ref.read(loginProvider.notifier).login(context);
                if (ref.read(loginProvider).isLoggedIn) {
                  context.replace('/navibar');
                }
              },
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Wanted sans',
                fontSize: 15 * S.Y_RATIO,
              ),
              decoration: InputDecoration(
                hintText: '비밀번호 입력',
                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Wanted sans',
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  left: S.X_RATIO * 20,
                  bottom: S.Y_RATIO * 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class CircleCheck extends StatefulWidget {
  const CircleCheck({super.key});

  @override
  _CircleCheckState createState() => _CircleCheckState();
}

class _CircleCheckState extends State<CircleCheck> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Positioned(
      left: 30 * S.X_RATIO,
      top: (434 + 44) * S.Y_RATIO,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isChecked = !isChecked;
          });
        },
        child: Container(
          width: 12 * S.X_RATIO,
          height: 12 * S.Y_RATIO,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white),
            color: isChecked ? Colors.white : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    return Positioned(
      left: 30 * S.X_RATIO,
      top: 514 * S.Y_RATIO,
      child: GestureDetector(
        onTap: () async {

          await ref.read(loginProvider.notifier).login(context);
          if (ref.read(loginProvider).isLoggedIn==true) {
            // ignore: use_build_context_synchronously
            context.replace('/navibar'); // 로그인 성공 시 홈 화면으로 이동
          }
        },
        child: Container(
          width: 300 * S.X_RATIO,
          height: 44 * S.Y_RATIO,
          decoration: BoxDecoration(
            color: const Color(0xFF0A82FF),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              '로그인',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Wanted sans',
                fontSize: 15 * S.Y_RATIO,
                height: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Positioned(
      left: 30 * S.X_RATIO,
      top: (528+50) * S.Y_RATIO,
      child: GestureDetector(
        onTap: () {
          context.push('/signin'); // GoRouter를 사용하여 '/home' 경로로 이동
        },
        child: Text(
          '회원가입',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Wanted sans',
            fontSize: 12*S.Y_RATIO,
            height: 0, // 높이 0으로 설정
          ),
        ),
      ),
    );
  }
}

class FindIdPwButton extends StatelessWidget {
  const FindIdPwButton({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Positioned(
      right: 30 * S.X_RATIO,
      top: (528+50) * S.Y_RATIO,
      child: GestureDetector(
        onTap: () {
          context.push('/findid'); // 아이디/비밀번호 찾기 버튼을 눌렀을 때 동작
        },
        child: Text(
          '아이디/비밀번호 찾기',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Wanted sans',
            fontSize: 12*S.Y_RATIO,
            height: 0, // 높이 0으로 설정
          ),
        ),
      ),
    );
  }
}

class Maintainlogin extends StatelessWidget {
  const Maintainlogin({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Positioned(
      left: 50 * S.X_RATIO,
      top: 474 * S.Y_RATIO,
      child:  Text(
        '로그인 상태 유지하기',
        style: TextStyle(
          color: Color(0xFFE5E6E7),
          fontSize: 12*S.Y_RATIO,
          fontFamily: 'Wanted Sans',
          fontWeight: FontWeight.w400,
          height: 0, // 높이 0으로 설정
        ),
      ),
    );
  }
}

class OrLines extends StatelessWidget {
  const OrLines({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Positioned(
      top: (528 + 90) * S.Y_RATIO,
      left: (MediaQuery.of(context).size.width - 300 * S.X_RATIO) / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 115 * S.X_RATIO,
            height: 1,
            color: const Color(0xFF0A82FF),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30 * S.X_RATIO),
            child: Text(
              '또는',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Wanted sans',
                fontSize: 12*S.Y_RATIO,
                height: 0,
              ),
            ),
          ),
          Container(
            width: 115 * S.X_RATIO,
            height: 1,
            color: const Color(0xFF0A82FF),
          ),
        ],
      ),
    );
  }
}

class ImageButtons extends StatelessWidget {
  const ImageButtons({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Positioned(
      top: (528 + 90 + 50) * S.Y_RATIO,
      left: 30 * S.X_RATIO,
      right: 30 * S.X_RATIO,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 50* S.X_RATIO,
            height: 50* S.X_RATIO,
            child: SvgPicture.asset('assets/ban/kakaologo.svg'),
          ),
          SizedBox(
            width: 50* S.X_RATIO,
            height: 50* S.X_RATIO,
            child: SvgPicture.asset('assets/ban/googlelogo.svg'),
          ),
          SizedBox(
            width: 50* S.X_RATIO,
            height: 50* S.X_RATIO,
            child: SvgPicture.asset('assets/ban/naverlogo.svg'),
          ),
        ],
      ),
    );
  }
}