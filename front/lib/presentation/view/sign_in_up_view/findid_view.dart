// ignore_for_file: camel_case_types, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/router/app_router.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/Pwre_view.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/findid_provider.dart';

final verificationProvider = StateProvider<bool>((ref) => false);

class FindID_view extends ConsumerStatefulWidget {
  const FindID_view({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _FindIDViewState createState() => _FindIDViewState();
}

class _FindIDViewState extends ConsumerState<FindID_view> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;

  final List<String> _years =
  List.generate(100, (i) => (DateTime.now().year - i).toString());
  final List<String> _months =
  List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
  List<String> _days =
  List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));

  @override
  Widget build(BuildContext context) {
    S.init(context);

    bool isButtonEnabled = _nameController.text.isNotEmpty &&
        _numberController.text.isNotEmpty &&
        _selectedYear != null &&
        _selectedMonth != null &&
        _selectedDay != null;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const Pflogo_ban(),
            Back_ban(onPressed: () {
              ref.read(verificationProvider.notifier).state = false;
              ref.read(appRouterProvider).pop('/');
            }),
            const Line_ban(),
            const textForgetID_ban(),
            const Longline_ban(),
            const TitleBirthBan(),
            Verifbutton_ban(
              isButtonEnabled: isButtonEnabled,
              onPressed: () async {
                final realName = _nameController.text;
                final phoneNumber = _numberController.text;
                final birthString =
                    '$_selectedYear-$_selectedMonth-$_selectedDay';
                DateTime? birth;
                try {
                  birth = DateTime.parse(birthString);
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("생년월일 형식이 올바르지 않습니다."),
                    ),
                  );
                  return;
                }

                await ref.read(findIdProvider.notifier).findId(
                  realName: realName,
                  phoneNumber: phoneNumber,
                  birth: birth,
                );

                final state = ref.read(findIdProvider);
                if (state.isFound) {
                  context.go('/idFound');
                } else if (state.errorMessage.isNotEmpty) {
                  showBottomSheet(context);
                }
              },
            ),
            Namebox_ban(controller: _nameController),
            Numberbox_ban(controller: _numberController),
            Verifibox_ban(
              onYearChanged: (y) {
                setState(() {
                  _selectedYear = y;
                  _updateDays();
                });
              },
              onMonthChanged: (m) {
                setState(() {
                  _selectedMonth = m;
                  _updateDays();
                });
              },
              onDayChanged: (d) => setState(() => _selectedDay = d),
              years: _years,
              months: _months,
              days: _days,
            ),
            const Idpwtext_ban(),
          ],
        ),
      ),
    );
  }

  void _updateDays() {
    if (_selectedMonth == '02') {
      final year = int.tryParse(_selectedYear ?? '') ?? 0;
      final isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      _days = List.generate(isLeap ? 29 : 28,
              (i) => (i + 1).toString().padLeft(2, '0'));
    } else if (['04', '06', '09', '11'].contains(_selectedMonth)) {
      _days = List.generate(30, (i) => (i + 1).toString().padLeft(2, '0'));
    } else {
      _days = List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
    }
    if (int.tryParse(_selectedDay ?? '')! > _days.length) {
      _selectedDay = null;
    }
  }
}

class Verifbutton_ban extends StatelessWidget {
  final bool isButtonEnabled;
  final VoidCallback onPressed;
  const Verifbutton_ban({
    super.key,
    required this.isButtonEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Padding(
      padding: EdgeInsets.only(top: S.Y_RATIO * 680, left: 30 * S.X_RATIO),
      child: InkWell(
        onTap: isButtonEnabled ? onPressed : null,
        child: Ink(
          decoration: BoxDecoration(
            color: isButtonEnabled
                ? const Color(0xFFFF7400)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15.0),
            border:
            Border.all(color: const Color(0xFFFF7400), width: 1),
          ),
          child: SizedBox(
            height: 45 * S.Y_RATIO,
            width: 300 * S.X_RATIO,
            child: Center(
              child: Text(
                '아이디 찾기',
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
      ),
    );
  }
}

class Namebox_ban extends StatelessWidget {
  final TextEditingController controller;
  const Namebox_ban({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Padding(
      padding: EdgeInsets.only(top: 410 * S.Y_RATIO, left: 30 * S.X_RATIO),
      child: Container(
        height: 44 * S.Y_RATIO,
        width: 300 * S.X_RATIO,
        decoration: BoxDecoration(
          color: const Color(0xFF21213F),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 12 * S.Y_RATIO,
            fontFamily: 'Wanted Sans',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF21213F),
            contentPadding: const EdgeInsets.only(left: 20, bottom: 5),
            focusedBorder: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFF21213F), width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            border: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFF21213F), width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: '이름 입력',
            hintStyle: TextStyle(
              fontSize: 12 * S.Y_RATIO,
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}


class Numberbox_ban extends StatelessWidget {
  final TextEditingController controller;
  const Numberbox_ban({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Padding(
      padding: EdgeInsets.only(top: 464 * S.Y_RATIO, left: 30 * S.X_RATIO),
      child: Container(
        height: 44 * S.Y_RATIO,
        width: 300 * S.X_RATIO,
        decoration: BoxDecoration(
          color: const Color(0xFF21213F),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: TextStyle(
            fontSize: 12 * S.Y_RATIO,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF21213F),
            contentPadding:
            EdgeInsets.only(left: 20 * S.X_RATIO, bottom: 5 * S.Y_RATIO),
            focusedBorder: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFF21213F), width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            border: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFF21213F), width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: '전화번호 입력(-제외)',
            hintStyle: TextStyle(
              fontSize: 12 * S.Y_RATIO,
              fontWeight: FontWeight.w400,
              fontFamily: 'Wanted Sans',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}


class Verifibox_ban extends StatelessWidget {
  final Function(String?) onYearChanged;
  final Function(String?) onMonthChanged;
  final Function(String?) onDayChanged;
  final List<String> years;
  final List<String> months;
  final List<String> days;

  const Verifibox_ban({
    super.key,
    required this.onYearChanged,
    required this.onMonthChanged,
    required this.onDayChanged,
    required this.years,
    required this.months,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 550 * S.Y_RATIO, left: 30 * S.X_RATIO),
          child: SizedBox(
            width: 300 * S.X_RATIO,
            height: 44 * S.Y_RATIO,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    hint: Text(
                      "년(4자)",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * S.Y_RATIO,
                        fontFamily: 'Wanted Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    value: null,
                    onChanged: onYearChanged,
                    items: years
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 12 * S.Y_RATIO,
                                fontFamily: 'Wanted Sans',
                              ),
                            )))
                        .toList(),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8 * S.Y_RATIO, horizontal: 6.5 * S.X_RATIO),
                      filled: true,
                      fillColor: const Color(0xFF21213F),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF3D3D91), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF21213F), width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),

                    ),
                  ),
                ),
                SizedBox(width: S.X_RATIO * 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                      hint: Text( "월",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12 * S.Y_RATIO,
                          fontFamily: 'Wanted Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    value: null,
                    onChanged: onMonthChanged,
                    items: months
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 12 * S.Y_RATIO,
                                fontFamily: 'Wanted Sans',
                              ),
                            )))
                        .toList(),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8 * S.Y_RATIO, horizontal: 6.5 * S.X_RATIO),
                      filled: true,
                      fillColor: const Color(0xFF21213F),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF3D3D91), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF21213F), width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),

                    )
                  ),
                ),
                SizedBox(width: S.X_RATIO * 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    hint: Text( "일",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * S.Y_RATIO,
                        fontFamily: 'Wanted Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    value: null,
                    onChanged: onDayChanged,
                    items: days
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 12 * S.Y_RATIO,
                                fontFamily: 'Wanted Sans',
                              ),
                            )))
                        .toList(),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8 * S.Y_RATIO, horizontal: 6.5 * S.X_RATIO),
                      filled: true,
                      fillColor: const Color(0xFF21213F),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF3D3D91), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF21213F), width: 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class Pflogo_ban extends StatelessWidget {
  const Pflogo_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      padding: EdgeInsets.only(
        top: S.Y_RATIO * 103,
      ),
      alignment: Alignment.topCenter,
      child: SvgPicture.asset(
        'assets/ban/logo_ban.svg',
      ),
    );
  }
}


class Line_ban extends StatelessWidget {
  const Line_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      padding: EdgeInsets.only(top: S.Y_RATIO * 276.5, left: S.X_RATIO * 50),
      child: SvgPicture.asset('assets/ban/shortline_ban.svg'),
    );
  }
}

//
class textForgetID_ban extends StatelessWidget {
  const textForgetID_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: S.Y_RATIO * 320, left: S.X_RATIO * 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '아이디를 잊으셨나요?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              SizedBox(height: S.Y_RATIO * 6),
              Text(
                '아래의 정보를 입력해 주세요.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
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

//
class Idpwtext_ban extends StatelessWidget {
  const Idpwtext_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 244 * S.Y_RATIO,
        left: 50 * S.X_RATIO,
        right:46 * S.X_RATIO,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '아이디 찾기',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * S.Y_RATIO,
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => const Pwre_view(),
                  transitionDuration: Duration.zero,
                ),
              );
            },
            child: Text(
              '비밀번호 재설정',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


//
class Longline_ban extends StatelessWidget {
  const Longline_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
        padding: EdgeInsets.only(top: S.Y_RATIO * 277.7, left: S.X_RATIO * 30),
        child: Container(
          width: S.X_RATIO * 300,
          height: 1.2,
          color: Colors.white,
        ));
  }
}

void showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        width: 360 * S.X_RATIO,
        height: 320 * S.Y_RATIO,
        decoration: const ShapeDecoration(
            color: Color(0xFF21213D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            )),
        child: Column(
          children: <Widget>[
            SizedBox(height: S.Y_RATIO * 29),
            Text(
              '아이디를 찾지 못했어요.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
            SizedBox(height: S.Y_RATIO * 31),
            Text(
              '입력해주신 정보로 가입된 아이디가 없어요.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            SizedBox(height: S.Y_RATIO * 11),
            Text(
              '이 정보를 이용해 새로 가입할 수 있어요.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            SizedBox(height: S.Y_RATIO * 11),
            Text(
              '지금 회원가입 하러 갈까요?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            SizedBox(height: S.Y_RATIO * 37),
            SignupButton_ban(onPressed: () {
              context.go('/signin');
            }),
            SizedBox(height: S.Y_RATIO * 10),
            Laterbutton_ban(onPressed: () {
              Navigator.of(context).pop();
            })
          ],
        ),
      );
    },
  );
}

//
//
class TitleBirthBan extends StatelessWidget {
  const TitleBirthBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 530, left: S.X_RATIO * 39.44),
      child: Text(
        '생년월일',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12 * S.Y_RATIO,
          fontFamily: 'Wanted Sans',
          fontWeight: FontWeight.w400,
          height: 0,
        ),
      ),
    );
  }
}

//
//
//
class SignupButton_ban extends StatelessWidget {
  final VoidCallback onPressed;

  const SignupButton_ban({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return GestureDetector(
      onTap: onPressed,
      child: SvgPicture.asset(
        'assets/ban/signupbutton_ban.svg',
      ),
    );
  }
}

//
class Laterbutton_ban extends StatelessWidget {
  final VoidCallback onPressed;

  const Laterbutton_ban({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return GestureDetector(
      onTap: onPressed,
      child: SvgPicture.asset(
        'assets/ban/laterbutton_ban.svg',
      ),
    );
  }
}