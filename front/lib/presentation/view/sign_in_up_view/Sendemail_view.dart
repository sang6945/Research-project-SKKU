// ignore_for_file: camel_case_types, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/Pwre2_provider.dart';
import '../../viewmodel/Pwre_provider.dart';

class Sendemail_view extends ConsumerStatefulWidget {
  const Sendemail_view({super.key});

  @override
  _SendemailviewState createState() => _SendemailviewState();
}

class _SendemailviewState extends ConsumerState<Sendemail_view> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isMatch = false; // 비밀번호 일치 여부를 저장하는 변수
  @override

  @override
  Widget build(BuildContext context) {
    S.init(context);

    final pwre2 = ref.watch(pwre2Provider);
    final pwre1 = ref.watch(pwreProvider);

    ref.listen<Pwre2State>(pwre2Provider, (prev, next) {
      if (next.passwordChanged) {
        context.go('/');
        ref.read(pwreProvider.notifier).reset();
        ref.read(pwre2Provider.notifier).reset();

      } else if (next.errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage)),
        );
      }
    });
    final isButtonEnabled = _isMatch && !pwre2.isLoading;

    return PopScope(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              const Completedsend_ban(),
              const Checkicon_ban(),
              const Sendmessage_ban(),
          PWInputFields(
            passwordController: _passwordController,
            confirmController: _confirmPasswordController,
            onMatchChanged: (bool match) {
              setState(() {
                _isMatch = match;
              });
            },),
              ResetButton(
                isButtonEnabled: isButtonEnabled,
                onPressed: () {
                  // 2단계 호출: setNewPassword
                  ref.read(pwre2Provider.notifier).setNewPassword(
                    email: pwre1.email,
                    newPassword: _confirmPasswordController.text,
                  );
                },
              ),

              if (pwre2.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}



class ResetButton extends StatelessWidget {
  final bool isButtonEnabled;
  final VoidCallback onPressed;

  const ResetButton(
      {super.key, required this.isButtonEnabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Padding(
      padding: EdgeInsets.only(top: S.Y_RATIO * 680, left: 30 * S.X_RATIO),
      child: InkWell(
        onTap: isButtonEnabled ? onPressed : null,
        child: Ink(
          decoration: BoxDecoration(
            color:
            isButtonEnabled ? const Color(0xFFFF7400) : Colors.transparent,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: const Color(0xFFFF7400), width: 1),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 45 * S.Y_RATIO,
            width: 300 * S.X_RATIO,
            child: Text(
              '비밀번호 재설정하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15 * S.Y_RATIO,
                fontWeight: FontWeight.w600,
                fontFamily: 'Wanted Sans',
              ),
            ),
          ),
        ),
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
          '비밀번호 재설정',
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

    final pwreState = ref.watch(pwreProvider);
    return Container(
      padding: EdgeInsets.only(top: S.Y_RATIO * 370),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            '${pwreState.email} 님의',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w800,
              height: 0,
            ),
          ),
          const Text(
            '변경하실 비밀번호를 입력해주세요!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w800,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class PWInputFields extends ConsumerStatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final void Function(bool)? onMatchChanged; // 비밀번호 일치 여부 전달 콜백
  const PWInputFields({
    super.key,
    required this.passwordController,
    required this.confirmController,
    this.onMatchChanged,
  });
  @override
  _PWInputFieldsState createState() => _PWInputFieldsState();
}

class _PWInputFieldsState extends ConsumerState<PWInputFields> {
  bool _isPasswordMatch = false;

  void _onPasswordChanged(String text) {
    bool match =
        widget.passwordController.text == widget.confirmController.text;
    if (match != _isPasswordMatch) {
      setState(() {
        _isPasswordMatch = match;
      });
      // 부모에게 변경된 값을 전달
      if (widget.onMatchChanged != null) {
        widget.onMatchChanged!(match);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: S.Y_RATIO * 450,
              left: S.X_RATIO * 30,
              right: S.X_RATIO * 30),
          child: TextField(
            controller: widget.passwordController,
            obscureText: true,
            onChanged: _onPasswordChanged,
            style: TextStyle(
              color: const Color(0xFF616193),
              fontSize: 12 * S.Y_RATIO,
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
            decoration: InputDecoration(
              hintText: '비밀번호 입력',
              hintStyle: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF21213F), width: 2),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              top: S.Y_RATIO * 10, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
          child: TextField(
            controller: widget.confirmController,
            obscureText: true,
            onChanged: _onPasswordChanged,
            style: TextStyle(
              color: widget.confirmController.text.isEmpty
                  ? const Color(0xFF616193)
                  : (_isPasswordMatch ? const Color(0xFF616193) : Colors.red),
              fontSize: 12 * S.Y_RATIO,
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
            decoration: InputDecoration(
              hintText: '비밀번호 재입력',
              hintStyle: TextStyle(
                color: widget.confirmController.text.isEmpty
                    ? Colors.white
                    : (_isPasswordMatch ? const Color(0xFF616193) : Colors.red),
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.confirmController.text.isEmpty
                      ? const Color(0xFF3D3D91)
                      : (_isPasswordMatch ? const Color(0xFF3D3D91) : Colors.red),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.confirmController.text.isEmpty
                      ? const Color(0xFF21213F)
                      : (_isPasswordMatch ? const Color(0xFF21213F) : Colors.red),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: !_isPasswordMatch &&
                  widget.confirmController.text.isNotEmpty
                  ? const Icon(Icons.error_outline, color: Colors.red)
                  : null,
            ),
          ),
        ),
        if (_isPasswordMatch)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: S.X_RATIO * 38, top: 3 * S.Y_RATIO),
              child: Text(
                '비밀번호가 일치합니다.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 8 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        if (!_isPasswordMatch && widget.confirmController.text.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: S.X_RATIO * 38, top: 3 * S.Y_RATIO),
              child: Text(
                '비밀번호가 일치하지 않습니다.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 8 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
