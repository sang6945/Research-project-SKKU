// ignore_for_file: camel_case_types, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/findid_view.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:fineplay/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/Pwre_provider.dart';

class Pwre_view extends ConsumerStatefulWidget {
  const Pwre_view ({super.key});

  @override
  _PwreviewState createState() => _PwreviewState();
}

class _PwreviewState extends ConsumerState<Pwre_view> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;

  final List<String> _years =
  List.generate(100, (index) => (DateTime.now().year - index).toString());
  final List<String> _months =
  List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> _days =
  List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pwreProvider);
    S.init(context);

    // ▶ build 안에서 listen 호출
    ref.listen<PwreState>(pwreProvider, (prev, next) {
      if (next.userFound) {
        context.go('/sendemail');
      } else if (next.errorMessage.isNotEmpty) {
        showBottomSheet(context);
      }
    });

    bool isButtonEnabled = _nameController.text.isNotEmpty &&
        _numberController.text.isNotEmpty &&
        _selectedYear != null &&
        _selectedMonth != null &&
        _selectedDay != null &&   !state.isLoading;
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(children: [
          const Pflogo_ban(),
          Back_ban(
              onPressed: () {
                // 1. 라우터로 홈으로 이동
                ref.read(appRouterProvider).go('/');
                // 2. pwreProvider 상태 초기화
                ref.read(pwreProvider.notifier).reset();
              },
          ),
          const Line_ban(),
          const Idpwtext_ban(),
          const Longline_ban(),
          const textForgetPW_ban(),
          Emailbox_ban(controller: _emailController),
          Namebox_ban(controller: _nameController),
          Numberbox_ban(controller: _numberController),
          const TitleBirth(),
          ResetButton(
            isButtonEnabled: isButtonEnabled,
            onPressed: () {
              final birthStr = '$_selectedYear-$_selectedMonth-$_selectedDay';
              DateTime? birth;
              try {
                birth = DateTime.parse(birthStr);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("생년월일 형식이 올바르지 않습니다.")),
                );
                return;
              }
              // 1단계 호출
              ref.read(pwreProvider.notifier).findUser(
                realName: _nameController.text,
                email: _emailController.text,
                phoneNumber: _numberController.text,
                birth: birth,
              );
            },
          ),

          if (state.isLoading)
            const Center(child: CircularProgressIndicator()),
          Verifibox_ban(
            onYearChanged: (String? year) {
              setState(() {
                _selectedYear = year;
                _updateDays();
              });
            },
            onMonthChanged: (String? month) {
              setState(() {
                _selectedMonth = month;
                _updateDays();
              });
            },
            onDayChanged: (String? day) {
              setState(() {
                _selectedDay = day;
              });
            },
            years: _years,
            months: _months,
            days: _days,
          ),
        ]),
      ),
    );
  }

  void _updateDays() {
    if (_selectedMonth == '02') {
      int year = int.parse(_selectedYear ?? '0');
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      setState(() {
        _days = List.generate(isLeapYear ? 29 : 28,
                (index) => (index + 1).toString().padLeft(2, '0'));
        int day = int.tryParse(_selectedDay ?? '0') ?? 0;
        if (day > _days.length) {
          _selectedDay = null;
        }
      });
    } else if (['04', '06', '09', '11'].contains(_selectedMonth)) {
      setState(() {
        _days = List.generate(
            30, (index) => (index + 1).toString().padLeft(2, '0'));
        int day = int.tryParse(_selectedDay ?? '0') ?? 0;
        if (day > _days.length) {
          _selectedDay = null;
        }
      });
    } else {
      setState(() {
        _days = List.generate(
            31, (index) => (index + 1).toString().padLeft(2, '0'));
      });
    }
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

class Back_ban extends StatelessWidget {
  final VoidCallback onPressed;

  const Back_ban({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      padding: EdgeInsets.only(top: S.Y_RATIO * 30, left: S.X_RATIO * 30),
      child: Backbutton_ban(onPressed: onPressed),
    );
  }
}

class Backbutton_ban extends StatelessWidget {
  final VoidCallback onPressed;

  const Backbutton_ban({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return GestureDetector(
      onTap: onPressed,
      child: SvgPicture.asset(
        'assets/ban/back_ban.svg',
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
      padding: EdgeInsets.only(top: S.Y_RATIO * 276, left: S.X_RATIO * 199),
      child: SizedBox(
          width: 100,
          child: SvgPicture.asset('assets/ban/shortline2_ban.svg')),
    );
  }
}

class Idpwtext_ban extends StatelessWidget {
  const Idpwtext_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 244 * S.Y_RATIO,
        left: 50 * S.X_RATIO,
        right: 46 * S.X_RATIO,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const FindID_view(),
                  transitionDuration: Duration.zero,
                ),
              );
            },
            child: Text(
              '아이디 찾기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ),
          Text(
            '비밀번호 재설정',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * S.Y_RATIO,
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}


class Longline_ban extends StatelessWidget {
  const Longline_ban({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
        padding: EdgeInsets.only(top: S.Y_RATIO * 277.7, left: S.X_RATIO * 30),
        child: Container(
          width: S.X_RATIO * 300,
          height: 1.2 * S.Y_RATIO,
          color: Colors.white,
        ));
  }
}

class textForgetPW_ban extends StatelessWidget {
  const textForgetPW_ban({super.key});

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
                '비밀번호를 잊으셨나요?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: S.Y_RATIO * 16,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              SizedBox(height: S.Y_RATIO * 6),
              Text(
                '가입하신 이메일로 재설정할 수 있어요.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: S.Y_RATIO * 16,
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

class Emailbox_ban extends StatelessWidget {
  final TextEditingController controller;
  const Emailbox_ban({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Padding(
      padding:
      EdgeInsets.only(top: S.Y_RATIO * 464, left: S.X_RATIO * 30),
      child: Container(
        height: 44 * S.Y_RATIO,
        width: 300 * S.X_RATIO,
        decoration: BoxDecoration(
          color: const Color(0xFF21213F),
          borderRadius: BorderRadius.circular(10),
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
            contentPadding: EdgeInsets.only(
                left: 20 * S.X_RATIO, bottom: 5 * S.Y_RATIO),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color(0xFF3D3D91), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color(0xFF21213F), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: '이메일 주소 입력',
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


class Namebox_ban extends StatelessWidget {
  final TextEditingController controller;
  const Namebox_ban({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Padding(
      padding:
      EdgeInsets.only(top: S.Y_RATIO * 410, left: S.X_RATIO * 30),
      child: Container(
        height: 44 * S.Y_RATIO,
        width: 300 * S.X_RATIO,
        decoration: BoxDecoration(
          color: const Color(0xFF21213F),
          borderRadius: BorderRadius.circular(10),
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
            contentPadding:
            const EdgeInsets.only(left: 20, bottom: 5),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color(0xFF3D3D91), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color(0xFF21213F), width: 1),
              borderRadius: BorderRadius.circular(10),
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


class Numberbox_ban extends StatefulWidget {
  final TextEditingController controller;
  const Numberbox_ban({super.key, required this.controller});


  @override
  _NumState createState() => _NumState();
}

class _NumState extends State<Numberbox_ban> {
  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Stack(
      children: [
        GestureDetector(
          child: Container(
            padding:
                EdgeInsets.only(top: S.Y_RATIO * 518, left: S.X_RATIO * 30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: S.Y_RATIO * 44,
              width: S.X_RATIO * 300,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: TextField(
                        controller: widget.controller,
                        style: TextStyle(
                      fontSize: S.Y_RATIO * 12,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF3D3D91),
                            width: 2.0), // 외각선 색상 및 두께 설정
                        borderRadius:
                            BorderRadius.circular(10.0), // 외각선 모서리 둥글게 설정
                      ),
                      // 포커스를 잃었을 때의 외각선 설정
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFF21213F),
                            width: 1.0), // 외각선 색상 및 두께 설정
                        borderRadius:
                            BorderRadius.circular(10.0), // 외각선 모서리 둥글게 설정
                      ),
                      contentPadding: EdgeInsets.only(
                          left: S.X_RATIO * 20, bottom: S.Y_RATIO * 5),
                      border: InputBorder.none,
                      hintText: "전화번호 입력(-제외)",
                      hintStyle: TextStyle(
                        fontSize: 12 * S.Y_RATIO,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Wanted Sans',
                        color: Colors.white,
                      ),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TitleBirth extends StatelessWidget {
  const TitleBirth({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 580, left: S.X_RATIO * 39.44),
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
          padding: EdgeInsets.only(top: 600 * S.Y_RATIO, left: 30 * S.X_RATIO),
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
                    hint: Text(
                      "월",
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

                    ),
                  ),
                ),
                SizedBox(width: S.X_RATIO * 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    hint: Text(
                      "일",
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
}void showBottomSheet(BuildContext context) {
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
