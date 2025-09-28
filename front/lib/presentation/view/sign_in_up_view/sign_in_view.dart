// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/router/app_router.dart';
import 'package:flutter/services.dart';
import 'package:fineplay/presentation/viewmodel/sign_in_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Signin_view extends ConsumerWidget {
  const Signin_view({super.key});
// _onVerify 함수 정의
  void _onVerify(bool isVerified) {
    // 인증이 성공했을 때 수행할 로직을 추가
    if (isVerified) {
      // 예: 인증 성공 시 특정 상태 업데이트
      if (kDebugMode) {
        print('인증 성공');
      }
    } else {
      // 예: 인증 실패 시 경고 메시지 표시
      if (kDebugMode) {
        print('인증 실패');
      }
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    S.init(context);

    ref.watch(signInProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            BackButtonBan(onPressed: () { ref.read(appRouterProvider).go('/');
      ref.invalidate(signInProvider);
      },),
            const LogoBan(),
            const PageNameBan(),
            const TitleIDBan(),
            const IDInputAndButton(),
            const TitlePWBan(),
            const PWInputFields(),
            const TitleNameBan(),
            const NameInputField(),
            const TitleNickNameBan(),
            const NickInputAndButton(),
            const TitleBirthBan(),
            const BirthInputFields(),
            const TitlePhoneBan(),
            PhoneInputBan(key: _phoneInputKey),
            const TitlePosition(),
            const PositionSelect(),
            CertNumInputBan(onVerify: _onVerify),
            const TermsContainerBan(),
          ],
        ),
      ),
    );
  }
}


class IDInputAndButton extends ConsumerStatefulWidget {
  const IDInputAndButton({super.key});

  @override
  _IDInputAndButtonState createState() => _IDInputAndButtonState();
}

class _IDInputAndButtonState extends ConsumerState<IDInputAndButton> {
  final TextEditingController _idController = TextEditingController();
  bool _isChecked = false;
  bool _isEmailValid = true; // 이메일 형식 체크 여부

  // 이메일 형식 검증
  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }

  Future<void> _checkDuplicateId() async {
    String enteredId = _idController.text;

    // 이메일 형식 검증
    if (!_isValidEmail(enteredId)) {
      setState(() {
        _isEmailValid = false; // 이메일 형식이 잘못되면 유효하지 않음
        _isChecked = false; // 중복 확인 비활성화
      });
      return;
    } else {
      setState(() {
        _isEmailValid = true; // 이메일 형식이 올바른 경우
      });
    }

    try {
      final response = await http.post(
        Uri.parse('https://fineplay.kr/api/auth/check-email-duplicate'), // 백엔드 API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': enteredId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'EXISTS') {
          // 아이디가 중복된 경우
          showDialog(
            context: context,
            builder: (BuildContext context) {
              S.init(context);

              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                backgroundColor: const Color(0xFF21213F),
                title: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 25 * S.Y_RATIO),
                      SizedBox(width: 8 * S.X_RATIO),
                      Text(
                        '중복 아이디 제한',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20 * S.Y_RATIO,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '입력하신 아이디는 이미 사용 중입니다.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * S.Y_RATIO,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '다른 아이디로 변경해 주세요!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * S.Y_RATIO,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: SizedBox(
                      width: 200 * S.X_RATIO,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          '변경하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * S.Y_RATIO,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          setState(() {
            _isChecked = false;
            ref.read(signInProvider.notifier).updateID(enteredId);
          });
        } else {
          // 아이디가 중복되지 않은 경우
          setState(() {
            _isChecked = true;
            ref.read(signInProvider.notifier).updateID(enteredId);
          });
        }
      } else {
        // 서버 오류 처리
        if (kDebugMode) {
          print('Failed to check ID: ${response.statusCode}');
        }
      }
    } catch (e) {
      // 네트워크 오류 처리
      if (kDebugMode) {
        print('Error checking ID: $e');
      }
    }
  }

  void _onEmailChanged(String text) {
    ref.read(signInProvider.notifier).updateID(text);
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: S.Y_RATIO * 182, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _idController,
                  onChanged: _onEmailChanged,
                  style: TextStyle(
                    color: const Color(0xFF616193),
                    fontSize: 12 * S.Y_RATIO,
                    fontFamily: 'Wanted Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                  decoration: InputDecoration(
                    hintText: '아이디 입력(이메일 주소)',
                    hintStyle: TextStyle(
                      color: const Color(0xFF616193),
                      fontSize: 12 * S.Y_RATIO,
                      fontFamily: 'Wanted Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF21213F), width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * S.X_RATIO),
              GestureDetector(
                onTap: _checkDuplicateId,
                child: SvgPicture.asset('assets/ban/duplicate_button_ban.svg'),
              ),
            ],
          ),
        ),
        if (!_isEmailValid)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: S.X_RATIO * 38, top: 3 * S.Y_RATIO),
              child: Text(
                '잘못된 이메일 형식입니다.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 8 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        if (_isChecked)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: S.X_RATIO * 38, top: 3 * S.Y_RATIO),
              child: Text(
                '사용 가능한 아이디입니다.',
                style: TextStyle(
                  color: Colors.green,
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



// 비밀번호 입력 필드
class PWInputFields extends ConsumerStatefulWidget {
  const PWInputFields({super.key});

  @override
  _PWInputFieldsState createState() => _PWInputFieldsState();
}

class _PWInputFieldsState extends ConsumerState<PWInputFields> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordMatch = false;

  void _onPasswordChanged(String text) {
    setState(() {
      _isPasswordMatch = (_passwordController.text == _confirmPasswordController.text);
      ref.read(signInProvider.notifier).updatePassword(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: S.Y_RATIO * 275, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
          child: TextField(
            controller: _passwordController,
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
                color: const Color(0xFF616193),
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF21213F), width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: S.Y_RATIO * 10, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            onChanged: _onPasswordChanged,
            style: TextStyle(
              color: _confirmPasswordController.text.isEmpty
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
                color: _confirmPasswordController.text.isEmpty
                    ? const Color(0xFF616193)
                    : (_isPasswordMatch ? const Color(0xFF616193) : Colors.red),
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _confirmPasswordController.text.isEmpty
                      ? const Color(0xFF3D3D91)
                      : (_isPasswordMatch ? const Color(0xFF3D3D91) : Colors.red),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _confirmPasswordController.text.isEmpty
                      ? const Color(0xFF21213F)
                      : (_isPasswordMatch ? const Color(0xFF21213F) : Colors.red),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: !_isPasswordMatch && _confirmPasswordController.text.isNotEmpty
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
        if (!_isPasswordMatch && _confirmPasswordController.text.isNotEmpty)
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

// 이름 입력 필드
class NameInputField extends ConsumerStatefulWidget {
  const NameInputField({super.key});

  @override
  _NameInputFieldState createState() => _NameInputFieldState();
}

class _NameInputFieldState extends ConsumerState<NameInputField> {
  final TextEditingController _nameController = TextEditingController();

  void _onNameChanged(String text) {
    ref.read(signInProvider.notifier).updaterealname(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 435, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
      child: TextField(
        controller: _nameController,
        onChanged: _onNameChanged,
        style: TextStyle(
          color: const Color(0xFF616193),
          fontSize: 12 * S.Y_RATIO,
          fontFamily: 'Wanted Sans',
          fontWeight: FontWeight.w400,
          height: 0,
        ),
        decoration: InputDecoration(
          hintText: '이름 입력',
          hintStyle: TextStyle(
            color: const Color(0xFF616193),
            fontSize: 12 * S.Y_RATIO,
            fontFamily: 'Wanted Sans',
            fontWeight: FontWeight.w400,
            height: 0,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF21213F), width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}

// 생년월일 입력 필드
class BirthInputFields extends ConsumerStatefulWidget {
  const BirthInputFields({super.key});

  @override
  _BirthInputFieldsState createState() => _BirthInputFieldsState();
}

class _BirthInputFieldsState extends ConsumerState<BirthInputFields> {
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;

  final List<String> _years = List.generate(100, (index) => (DateTime.now().year - index).toString());
  final List<String> _months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> _days = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  void _onBirthChanged() {
    if (_selectedYear != null && _selectedMonth != null && _selectedDay != null) {
      ref.read(signInProvider.notifier).updateUserBirth('$_selectedYear-$_selectedMonth-$_selectedDay');
    }
  }

  void _updateDays() {
    if (_selectedMonth == '02') {
      int year = int.parse(_selectedYear ?? '0');
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      setState(() {
        _days = List.generate(isLeapYear ? 29 : 28, (index) => (index + 1).toString().padLeft(2, '0'));
        int day = int.tryParse(_selectedDay ?? '0') ?? 0;
        if (day > _days.length) {
          _selectedDay = null;
        }
      });
    } else if (['04', '06', '09', '11'].contains(_selectedMonth)) {
      setState(() {
        _days = List.generate(30, (index) => (index + 1).toString().padLeft(2, '0'));
        int day = int.tryParse(_selectedDay ?? '0') ?? 0;
        if (day > _days.length) {
          _selectedDay = null;
        }
      });
    } else {
      setState(() {
        _days = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 605, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedYear,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedYear = newValue;
                  _onBirthChanged();
                  _updateDays();
                });
              },
              items: _years.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8 * S.Y_RATIO, horizontal: 6.5 * S.X_RATIO),
                filled: true,
                fillColor: const Color(0xFF21213F),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              hint: Text(
                '년(4자)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              isExpanded: true,
            ),
          ),
          SizedBox(width: S.X_RATIO * 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedMonth,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMonth = newValue;
                  _onBirthChanged();
                  _updateDays();
                });
              },
              items: _months.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8 * S.Y_RATIO, horizontal: 6.5 * S.X_RATIO),
                filled: true,
                fillColor: const Color(0xFF21213F),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              hint: Text(
                '월',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              isExpanded: true,
            ),
          ),
          SizedBox(width: S.X_RATIO * 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDay,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDay = newValue;
                  _onBirthChanged();
                });
              },
              items: _days.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8 * S.Y_RATIO, horizontal: 6.5 * S.X_RATIO),
                filled: true,
                fillColor: const Color(0xFF21213F),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              hint: Text(
                '일',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }
}

// 전화번호 입력 필드
class PhoneInputBan extends ConsumerStatefulWidget {
  @override
  // ignore: overridden_fields
  final GlobalKey<PhoneInputBanState> key;
  const PhoneInputBan({required this.key}) : super(key: key);

  @override
  PhoneInputBanState createState() => PhoneInputBanState();
}

class PhoneInputBanState extends ConsumerState<PhoneInputBan> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isVerified = false;


  void _onVerified(bool verified) {
    setState(() {
      _isVerified = verified;
    });
  }

  void _onSendAttempt() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(top: 690 * S.Y_RATIO, left: 30 * S.X_RATIO),
      child: Stack(
        children: [
          SizedBox(
            width: 200*S.X_RATIO,
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              style: TextStyle(
                color: _isVerified ? Colors.grey : const Color(0xFF616193),
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 1.5 * S.Y_RATIO,
              ),
              decoration: InputDecoration(
                hintText: '전화번호(-제외)',
                hintStyle: TextStyle(
                  color: _isVerified ? Colors.grey : const Color(0xFF616193),
                  fontSize: 12 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.5 * S.Y_RATIO,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF21213F), width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              readOnly: _isVerified, // 인증되면 입력 불가
            ),
          ),
          Container(
            margin: EdgeInsets.only( left: 220 * S.X_RATIO),
            child: VerificationButton(
              phoneController: _phoneController,  // 전화번호 컨트롤러 전달
                onVerified: _onVerified,
              onSend: _onSendAttempt,
            ),
          ),

          Visibility(
            visible: _isVerified,
            child: Padding(
              padding: EdgeInsets.only(top: S.Y_RATIO * 58.0, left: S.X_RATIO * 8),
              child: Text(
                '인증번호 전송에 성공하였습니다.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 8*S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}





class VerificationButton extends ConsumerStatefulWidget {
  final TextEditingController phoneController;
  final Function(bool) onVerified;
  final VoidCallback onSend;

  const VerificationButton({super.key, required this.phoneController, required this.onVerified, required this.onSend});

  @override
  _VerificationButtonState createState() => _VerificationButtonState();
}


  class _VerificationButtonState extends ConsumerState<VerificationButton> {
    Future<void> _sendVerificationCode() async {
      widget.onSend();

      String phoneNumber = widget.phoneController.text;

      if (phoneNumber.isEmpty) {
        if (kDebugMode) {
          print('전화번호를 입력해주세요');
        }
        return;
      }

      try {
        final response = await http.post(
          Uri.parse('https://fineplay.kr/api/auth/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phoneNum': phoneNumber}),
        );

        if (response.statusCode == 200) {
          // 인증번호 전송 성공
          if (kDebugMode) {
            print("인증번호 전송 완료");
          }

          ref.read(signInProvider.notifier).updatePhoneNumber(phoneNumber);
          widget.onVerified(true); // 인증 성공 시 상태 변경



        } else {
          // 서버 오류 처리
          if (kDebugMode) {
            print("Failed to send verification code: ${response.statusCode}");
          }
          widget.onVerified(false); // 인증 실패 시 상태 변경
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("인증 번호 전송에 실패하였습니다.",style: TextStyle(color: Colors.red),)));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error sending verification code: $e');
        }
        widget.onVerified(false); // 네트워크 오류 발생 시 인증 실패 처리
      }
    }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return ElevatedButton(
      onPressed: _sendVerificationCode,  // 인증번호 전송 버튼 클릭 시 호출
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFFF7400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),fixedSize: Size(80 * S.X_RATIO, 45 * S.Y_RATIO),
        padding: EdgeInsets.symmetric(vertical: 0 * S.Y_RATIO, horizontal: 0 * S.X_RATIO),
      ),
      child: Text(
          '인증번호 전송',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10*S.Y_RATIO,
            fontFamily: 'Wanted Sans',
            fontWeight: FontWeight.w400,
          ),
        ),

    );
  }
}


class CertNumInputBan extends ConsumerStatefulWidget {
  final Function(bool) onVerify;

  const CertNumInputBan({super.key, required this.onVerify});

  @override
  _CertNumInputBanState createState() => _CertNumInputBanState();
}

class _CertNumInputBanState extends ConsumerState<CertNumInputBan> {
  final TextEditingController _certController = TextEditingController();
  bool _isVerified = false;
  bool _isError = false;

  // 인증번호 확인 요청
  Future<void> _verifyCode(String value) async {
    if (value.length == 6) { // 6자 입력되었을 때만 API 호출
      String phoneNumber = ref.read(signInProvider).phoneNumber; // 전화번호를 provider에서 읽어오기

      try {
        final response = await http.post(
          Uri.parse('https://fineplay.kr/api/auth/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phoneNum': phoneNumber, 'certificationCode': value}),
        );

        if (response.statusCode == 200) {
          // 인증번호 확인 성공
          setState(() {
            _isVerified = true;
            _isError = false;
          });
          widget.onVerify(true);
        } else {
          // 인증번호 불일치
          setState(() {
            _isVerified = false;
            _isError = true;
          });
          widget.onVerify(false);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error verifying code: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(top: 765 * S.Y_RATIO, left: 30 * S.X_RATIO, right: 30 * S.X_RATIO),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _certController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)], // 6자리로 제한
            onChanged: _verifyCode, // 입력값 변경 시마다 _verifyCode 호출
            style: TextStyle(
              color: _isVerified ? Colors.grey : const Color(0xFF616193),
              fontSize: 12 * S.Y_RATIO,
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w400,
              height: 1.5 * S.Y_RATIO,
            ),
            decoration: InputDecoration(
              hintText: '인증번호 6자리 입력',
              hintStyle: TextStyle(
                color: _isVerified ? Colors.grey : const Color(0xFF616193),
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 1.5 * S.Y_RATIO,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF21213F), width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            readOnly: _isVerified, // 인증되면 입력 불가
          ),
          if (_isVerified)
            Padding(
              padding: EdgeInsets.only(top: S.Y_RATIO * 3.0, left: S.X_RATIO * 8),
              child: const Text(
                '인증번호가 일치합니다.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 8,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (_isError)
            Padding(
              padding: EdgeInsets.only(top: 8.0, left: S.X_RATIO * 8),
              child: const Text(
                '인증번호가 일치하지 않습니다.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 8,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


// 약관 동의 필드
class TermsContainerBan extends ConsumerStatefulWidget {
  const TermsContainerBan({super.key});

  @override
  _TermsContainerBanState createState() => _TermsContainerBanState();
}

class _TermsContainerBanState extends ConsumerState<TermsContainerBan> {
  bool _isCheckedAll = false;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isChecked3 = false;
  bool _isChecked4 = false;

  void _syncAllCheckboxState() {
    setState(() {
      _isCheckedAll = _isChecked1 && _isChecked2 && _isChecked3 && _isChecked4;
    });
  }

  void _updateCertifications() {
    // 모든 인증 체크박스의 상태를 전달하여 업데이트
    ref.read(signInProvider.notifier).updateCert(_isChecked1, _isChecked2, _isChecked3, _isChecked4);
  }

  void _showDetailSheet(BuildContext context, String title, String content) {
    S.init(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: const Color(0xFF21213F),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85, // 화면의 85% 높이까지
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18 * S.Y_RATIO,
                    color: Colors.white, fontFamily: 'Wanted Sans',),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: TextStyle(fontSize: 13 * S.Y_RATIO,
                        color: Colors.white,
                        fontFamily: 'Wanted Sans',),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("닫기", style: TextStyle(
                        color: Colors.deepOrange, fontSize: 16*S.Y_RATIO,  fontFamily: 'Wanted Sans',)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  final String termsContent2 = '''
본 약관은 파인플레이(이하 “서비스”라 합니다)가 제공하는 모바일 애플리케이션 및 관련 서비스(이하 “앱”)의 이용과 관련하여 회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.



⁙ 제1조 (목적)

본 약관은 파인플레이 앱의 이용과 관련하여 회사와 회원 간의 권리, 의무, 책임 및 기타 필요한 사항을 규정하는 것을 목적으로 합니다.



⁙ 제2조 (정의)

1. 회원: 본 약관에 동의하고 앱을 이용하는 자.
2. 서비스: 파인플레이 앱을 통해 제공되는 회원가입, 팀 관리, 경기 및 스탯 분석, 알림, 기타 부가 기능을 말합니다.
3. 콘텐츠: 서비스 내에서 회원이 제공하거나 이용할 수 있는 정보, 데이터, 이미지, 통계자료 등을 포함합니다.
4. 아이디(ID): 회원 식별과 서비스 이용을 위해 회원이 설정한 이메일 또는 고유 계정.
5. 비밀번호: 회원의 계정을 보호하기 위해 설정하는 문자와 숫자의 조합.



⁙ 제3조 (약관의 효력 및 변경)

1. 본 약관은 회원이 앱을 설치·가입 시 동의한 때부터 효력이 발생합니다.
2. 회사는 관련 법령을 위반하지 않는 범위에서 약관을 변경할 수 있으며, 변경 시 사전 고지합니다.
3. 회원이 변경된 약관에 동의하지 않을 경우 서비스 이용을 중단하고 회원탈퇴를 요청할 수 있습니다.



⁙ 제4조 (회원가입 및 계정 관리)

1. 회원가입은 본 약관에 동의하고 필요한 정보를 입력함으로써 이루어집니다.
2. 회원은 본인의 정보만을 제공해야 하며, 타인의 정보를 도용할 수 없습니다.
3. 회원은 계정 및 비밀번호 관리에 대한 책임을 가지며, 이를 제3자에게 양도하거나 공유할 수 없습니다.



⁙ 제5조 (서비스의 제공 및 변경)

1. 회사는 다음과 같은 서비스를 제공합니다.
    - 생활스포츠 경기 기록 및 분석
    - 개인 및 팀 스탯 관리
    - 사용자 검색 및 비교 기능
    - 알림 및 커뮤니티 관련 기능
2. 회사는 서비스 개선을 위해 일부 기능을 추가, 변경 또는 중단할 수 있으며, 사전 고지합니다.



⁙ 제6조(회원의 의무)

회원은 본 약관 및 관계 법령을 준수하여야 하며, 다음 각 호의 행위를 하여서는 안 됩니다.

1. 타인의 계정을 도용하거나 개인정보를 무단으로 수집, 이용, 제공하는 행위
2. 서비스 운영을 고의로 방해하거나 시스템에 부정 접근을 시도하는 행위
3. 허위의 정보를 입력하거나 다른 회원을 사칭하는 행위
4. 불법적인 정보, 음란물, 폭력적인 내용을 유포하는 행위
5. 서비스와 관련 없는 영리 목적의 광고, 홍보를 하는 행위
6. 기타 공공질서 및 미풍양속에 반하는 행위
    
    회원이 제1항을 위반한 경우 회사는 서비스 이용을 제한하거나 회원 자격을 정지 및 탈퇴 처리할 수 있습니다.
    



⁙ 제7조(개인정보 보호)

1. 회사는 회원의 개인정보를 보호하기 위해 관련 법령을 준수하고, 개인정보 처리방침을 따릅니다.
2. 회사는 서비스 제공을 위해 필요한 최소한의 개인정보만을 수집하며, 회원의 개인정보는 회사의 개인정보 처리방침에 따라 보호됩니다.
3. 회원은 언제든지 본인의 개인정보 열람, 수정, 삭제를 요청할 수 있습니다.



⁙ 제8조 (지적재산권)

1. 서비스 내 제공되는 콘텐츠에 대한 저작권 및 기타 지적재산권은 회사에 귀속합니다.
2. 회원이 작성한 콘텐츠(팀 정보, 스탯 기록 등)에 대한 권리는 해당 회원에게 있으나, 회사는 서비스 운영 및 홍보를 위해 이를 사용할 수 있습니다.



⁙ 제9조(서비스의 제공 및 변경)

1. 회사는 다음과 같은 서비스를 제공합니다.
    - 생활스포츠 경기 기록 및 분석
    - 개인 및 팀 스탯 관리
    - 사용자 검색 및 비교 기능
    - 알림 및 커뮤니티 관련 기능
2. 회사는 서비스 개선을 위해 일부 기능을 추가, 변경 또는 중단할 수 있으며, 사전 고지합니다.
3. 서비스 제공이 중단되는 경우, 회사는 사전 또는 사후에 공지하며, 서비스 중단으로 인해 발생하는 회원의 손해에 대해서는 회사의 책임이 제한됩니다.



⁙ 제10조 (책임의 제한)

1. 회사는 회원이 서비스 이용 과정에서 기대하는 결과를 보장하지 않습니다.
2. 회사는 회원 간 또는 회원과 제3자 간에 발생한 분쟁에 개입하지 않으며, 그에 대한 책임을 지지 않습니다.



⁙ 제11조 (해지 및 탈퇴)

1. 회원은 언제든지 앱 내 탈퇴 기능을 통해 회원탈퇴를 요청할 수 있습니다.
2. 회원탈퇴 시 서비스 내 저장된 데이터는 관련 법령 및 개인정보처리방침에 따라 처리됩니다.



⁙ 제12조 (게시물 관리)

1. 회원이 앱 내에 작성한 게시물(팀 게시판, 경기 기록 등)의 권리와 책임은 회원 본인에게 있습니다.
2. 회사는 다음 각 호에 해당하는 게시물은 사전 통지 없이 삭제할 수 있습니다.
    1. 타인의 권리를 침해하거나 명예를 훼손하는 경우
    2. 불법적인 정보, 음란물, 폭력적인 내용을 포함한 경우
    3. 서비스 목적과 무관하거나 상업적 광고 목적의 경우
3. 회원 탈퇴 시 회원이 작성한 게시물은 삭제되지 않으며, 필요한 경우 회원이 직접 삭제하여야 합니다.



⁙ 제13조 (저작권의 귀속 및 이용제한)

1. 서비스 및 그 안에 포함된 콘텐츠에 대한 저작권과 지적재산권은 회사에 귀속됩니다.
2. 회원은 회사의 사전 승낙 없이 서비스 내 콘텐츠를 복제, 전송, 출판, 배포, 방송, 2차적 저작물 작성 등 영리 목적으로 이용할 수 없습니다.



⁙ 제14조 (면책 조항)

1. 회사는 천재지변, 전쟁, 테러, 해킹, 시스템 장애 등 불가항력적 사유로 인해 서비스를 제공할 수 없는 경우 책임을 지지 않습니다.
2. 회사는 회원이 앱을 통해 얻은 정보나 자료의 신뢰성 및 정확성에 대하여 책임을 지지 않습니다.
3. 회사는 회원 상호 간 또는 회원과 제3자 간의 분쟁에 개입하지 않으며, 그로 인한 손해에 대하여 책임을 지지 않습니다.



⁙ 제15조 (손해배상)

1. 회원이 본 약관을 위반하여 회사에 손해를 끼친 경우, 회원은 회사에 발생한 모든 손해를 배상하여야 합니다.
2. 회사가 회원에게 손해를 끼친 경우, 고의 또는 중대한 과실이 없는 한 책임을 지지 않습니다.



⁙ 제16조 (약관의 해석 및 준거법)

1. 본 약관에서 정하지 아니한 사항과 해석은 관계 법령 및 상관례에 따릅니다.
2. 본 약관은 대한민국 법률에 따라 해석됩니다.



⁙ 제17조 (분쟁 해결)

1. 서비스 이용과 관련하여 회사와 회원 간에 발생한 분쟁은 원칙적으로 상호 협의를 통해 해결합니다.
2. 협의로 해결되지 않는 분쟁에 대해서는 민사소송법상의 관할법원에 제소합니다.

''';

  final String termsContent3 ='''
파인플레이는 서비스를 제공하기 위해 필요한 최소한의 개인정보만을 수집하며, 개인정보 수집 및 이용에 대한 동의를 얻습니다. 수집된 개인정보는 개인정보 처리방침에 따라 안전하게 관리되며, 그 목적 이외의 용도로는 사용되지 않습니다.

 1. 수집하는 개인정보 항목

파인플레이는 회원가입 및 서비스 이용을 위해 다음과 같은 개인정보를 수집합니다.

- 필수항목
    - 이름: 서비스 제공을 위한 회원 식별
    - 이메일 주소: 서비스 알림, 이벤트 정보 제공 및 고객 지원
    - 전화번호: 회원 인증 및 서비스 관련 안내
    - 생년월일: 연령대에 따른 맞춤형 서비스 제공
    - 프로필 사진: 사용자 맞춤형 프로필 제공
    - 서비스 이용 기록: 회원의 서비스 이용 분석 및 맞춤형 콘텐츠 제공
- 선택항목
    - 성별: 개인화된 서비스 제공
    - 주소: 배송 서비스 제공 (이용 시)
    - 직업 및 관심사: 맞춤형 이벤트 및 프로모션 제공

 2. 개인정보 수집 및 이용 목적

수집된 개인정보는 다음의 목적으로 이용됩니다.

- 회원 관리: 회원가입, 로그인, 인증 및 서비스 제공을 위한 본인 확인
- 서비스 제공: 맞춤형 서비스 제공, 서비스 이용에 대한 피드백 및 고객 지원
- 이벤트 및 프로모션: 이벤트, 프로모션, 서비스 업데이트 등의 정보 제공
- 서비스 개선 및 분석: 서비스 품질 향상 및 고객 맞춤형 콘텐츠 제공을 위한 데이터 분석
- 법적 의무 이행: 법적 요구사항을 준수하기 위한 정보 제공

 3. 개인정보 보유 및 이용 기간

파인플레이는 개인정보를 수집한 목적을 달성한 후에는 해당 정보를 즉시 삭제합니다. 단, 법적 의무를 준수하기 위해 특정 정보를 일정 기간 동안 보관할 수 있습니다.

- 보유기간: 서비스 제공 기간 동안
- 보관항목: 법적 요구 사항에 의한 정보(예: 거래 기록 등)는 관련 법령에 따라 일정 기간 보관
- 삭제 시점: 서비스 탈퇴 후 30일 이내에 모든 개인정보 삭제

 4. 개인정보의 제3자 제공

파인플레이는 원칙적으로 사용자의 개인정보를 제3자에게 제공하지 않습니다. 단, 다음과 같은 경우에는 예외적으로 개인정보를 제공할 수 있습니다.

- 법령에 의한 요구: 법적인 요구나 규제에 의해 개인정보 제공이 필요한 경우
- 서비스 개선을 위한 제휴사와의 협력: 제휴사와 협력하여 제공하는 서비스에 대한 정보 제공 (제휴사와의 계약에 따라 제한적으로 제공)
- 긴급 상황: 사용자의 생명, 신체, 재산 보호를 위해 긴급하게 개인정보를 제공해야 할 경우

 5. 개인정보의 안전성 확보 조치

파인플레이는 회원의 개인정보를 보호하기 위해 다음과 같은 기술적, 관리적 보안 조치를 취하고 있습니다.

- 접근 제어: 개인정보에 대한 접근 권한을 제한하여 불법적인 접근을 차단
- 정기적인 보안 점검: 서버 및 시스템의 보안을 강화하고, 해킹 시도나 보안 위협에 대응
- 개인정보 처리 담당자 교육: 개인정보 보호 및 보안 교육을 통해 내부 직원의 개인정보 보호 인식 강화

 6 회원의 권리와 행사 방법

회원은 언제든지 자신의 개인정보에 대한 열람, 수정, 삭제를 요청할 수 있습니다. 이를 위해서는 아래와 같은 방법을 통해 직접 요청하실 수 있습니다.

- 개인정보 열람: 개인정보가 정확한지 확인할 수 있는 권리
- 개인정보 수정: 부정확한 개인정보를 수정할 수 있는 권리
- 개인정보 삭제: 서비스 탈퇴 시 개인정보 삭제 요청 가능

회원은 서비스 내 설정을 통해 개인정보 처리 방침을 확인하고, 필요시 정보 수정을 요청하거나, 직접 탈퇴할 수 있습니다.

 7. 개인정보 처리방침 변경

본 개인정보 처리방침은 법령의 변경, 서비스의 변경 등 사유에 의해 수시로 변경될 수 있습니다. 변경된 사항은 앱 내에서 공지하거나, 이메일 등을 통해 회원에게 사전 안내 드립니다.
   ''';

  final String termsContent4 ='''
파인플레이는 귀하께 더 나은 서비스와 혜택을 제공하기 위해 이벤트와 마케팅 커뮤니케이션을 진행할 수 있습니다.

 1. 이벤트/프로모션 알림

- 파인플레이는 최신 이벤트, 프로모션, 서비스 업데이트에 관한 정보를 귀하에게 제공할 수 있습니다.
- 이벤트나 프로모션에 관한 이메일, 푸시 알림, 문자 메시지 등을 통해 정보를 전달할 수 있습니다.

 2. 마케팅 목적의 정보 수집 및 활용

- 귀하의 사용 기록과 활동 데이터를 마케팅 분석, 서비스 개선 및 개인화된 마케팅을 위한 자료로 활용할 수 있습니다.
- 이를 통해 파인플레이는 맞춤형 서비스 및 광고, 개인화된 마케팅 콘텐츠를 제공할 수 있습니다.

 3. 타사 제휴 마케팅

- 파인플레이는 제휴사와 협력하여 마케팅 활동을 진행할 수 있습니다. 귀하의 정보가 제휴사와 공유되어 관련 서비스를 제공받을 수 있습니다.
- 제휴사의 프로모션 및 이벤트 정보를 제공받을 수 있습니다.



 개인정보 보호

- 귀하의 개인정보는 개인정보 처리방침에 따라 안전하게 관리되며, 동의한 목적 이외의 용도로는 사용되지 않습니다.

주의사항:

- 이벤트/마케팅 정보 수신을 원하지 않으시면 언제든지 설정에서 수신을 거부하거나 동의를 철회하실 수 있습니다.
- 동의하지 않으셔도 서비스 이용에 제한은 없습니다.
  ''';

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 930, left: S.X_RATIO * 36, right: S.X_RATIO * 36),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.5),
                ),
                side: BorderSide(
                  color: _isCheckedAll ? const Color(0xFFFF7400) : const Color(0xFF616193),
                  width: 1,
                ),
                checkColor: Colors.white,
                activeColor: const Color(0xFFFF7400),
                value: _isCheckedAll,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isCheckedAll = newValue ?? false;
                    _isChecked1 = newValue ?? false;
                    _isChecked2 = newValue ?? false;
                    _isChecked3 = newValue ?? false;
                    _isChecked4 = newValue ?? false;
                    _updateCertifications(); // 여기서 updateCert 호출

                  });
                },
              ),
              Text(
                'FINE PLAY 약관 모두 동의',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13 * S.Y_RATIO,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Wanted Sans',
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * S.Y_RATIO),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: const Color(0xFF21213F)),
            ),
            child: Column(

              children: [

                _buildTermsRow(

                  '만 14세 이상입니다 (필수)',

                  _isChecked1,

                      (newValue) {

                    setState(() {

                      _isChecked1 = newValue!;

                      _syncAllCheckboxState();

                      _updateCertifications();

                    });

                  },

                      () => _showDetailSheet(context, '만 14세 이상', "본 서비스는 14세 이상 사용을 권장합니다."),

                ),
                _buildTermsRow(

                  '이용약관 동의 (필수)',

                  _isChecked2,

                      (newValue) {

                    setState(() {

                      _isChecked2 = newValue!;

                      _syncAllCheckboxState();

                      _updateCertifications();

                    });

                  },

                      () => _showDetailSheet(context, '파인플레이 이용약관', termsContent2),

                ),

                _buildTermsRow(

                  '개인정보 수집 및 이용 동의 (필수)',

                  _isChecked3,

                      (newValue) {

                    setState(() {

                      _isChecked3 = newValue!;

                      _syncAllCheckboxState();

                      _updateCertifications();

                    });

                  },

                      () => _showDetailSheet(context, '개인정보 수집 및 이용 동의', termsContent3),

                ),

                _buildTermsRow(

                  '이벤트/마케팅 수신 동의 (선택)',

                  _isChecked4,

                      (newValue) {

                    setState(() {

                      _isChecked4 = newValue!;

                      _syncAllCheckboxState();

                      _updateCertifications();

                    });

                  },

                      () => _showDetailSheet(context, '이벤트/마케팅 수신 동의', termsContent4),

                ),
              ],
            ),
          ),
          SizedBox(height: 20 * S.Y_RATIO),
          InkWell(
            onTap: ref.read(signInProvider).isButtonEnabled
                ? () async {
              // 가입 완료 버튼 클릭 시 실행할 코드
              final signInState = ref.read(signInProvider);

              // JSON 데이터 생성
              final data = {
                'realName': signInState.realname,
                'nickName' :signInState.nickName,
                'password': signInState.password,
                'email': signInState.email,
                'phoneNumber': signInState.phoneNumber,
                'position': signInState.position,
                'birth': signInState.birth,  // 생년월일 필드 (추가해야 함)
                'boolcert1': signInState.boolCert1,
                'boolcert2': signInState.boolCert2,
                'boolcert3': signInState.boolCert3,
                'boolcert4': signInState.boolCert4,
              };



              try {
                final response = await http.post(
                  Uri.parse('https://fineplay.kr/api/auth/sign-up'),  // 서버의 URL로 변경해야 함
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(data),
                );

                if (response.statusCode == 200) {
                  // 성공적으로 가입이 완료된 경우 처리
                  if (kDebugMode) {
                    print('가입 성공');
                  }
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("회원가입이 완료되었습니다.")));
                  Navigator.pop(context);
                  ref.invalidate(signInProvider);

                  // 성공 메시지를 보여주거나 다른 페이지로 이동
                } else {
                  // 실패한 경우 처리
                  if (kDebugMode) {
                    print('가입 실패: ${response.body}');
                  }
                  // 오류 메시지를 사용자에게 보여줌
                }
              } catch (e) {
                // 네트워크 오류 처리
                if (kDebugMode) {
                  print('Error: $e');
                }
              }
            }
                :  () {
              if (kDebugMode) {
                print('가입 버튼이 비활성화 상태입니다');
              }  // 비활성화 상태 로그
            },
            child: Ink(
              decoration: BoxDecoration(
                color: ref.read(signInProvider).isButtonEnabled ? const Color(0xFFFF7400) : Colors.transparent,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: const Color(0xFFFF7400), width: 1),
              ),
              child: Container(
                alignment: Alignment.center,
                height: 45 * S.Y_RATIO,
                width: double.infinity,
                child: Text(
                  '가입하기',
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
          SizedBox(height: 100 * S.Y_RATIO),
        ],
      ),
    );
  }

  Widget _buildTermsRow(String title, bool value, ValueChanged<bool?> onChanged, VoidCallback onDetailPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0 * S.Y_RATIO),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.5),
            ),
            side: BorderSide(
              color: value ? const Color(0xFFFF7400) : const Color(0xFF616193),
            ),
            checkColor: Colors.white,
            activeColor: const Color(0xFFFF7400),
            value: value,
            onChanged: onChanged,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextButton(
            onPressed:
            onDetailPressed,
            child: Text(
              '상세보기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9 * S.Y_RATIO,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 기본적인 UI 컴포넌트들

class BackButtonBan extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonBan({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    S.init(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(top: S.Y_RATIO * 38.76, left: S.X_RATIO * 30, right: S.X_RATIO * 318.27),
        child: SvgPicture.asset('assets/ban/back_icon_ban.svg'),
      ),
    );
  }
}

class LogoBan extends StatelessWidget {
  const LogoBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);

    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 53.34),
      alignment: Alignment.topCenter,
      child: SvgPicture.asset('assets/ban/Plogo_ban.svg'),
    );
  }
}

class PageNameBan extends StatelessWidget {
  const PageNameBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 116.58),
      alignment: Alignment.topCenter,
      child: Text(
        '회원가입',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18 * S.Y_RATIO,
          fontFamily: 'Wanted Sans',
          fontWeight: FontWeight.w800,
          height: 0,
        ),
      ),
    );
  }
}

class TitleIDBan extends StatelessWidget {
  const TitleIDBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 162, left: S.X_RATIO * 39.47),
      child: Text(
        '아이디',
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

class TitlePWBan extends StatelessWidget {
  const TitlePWBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 255, left: S.X_RATIO * 39.44),
      child: Text(
        '비밀번호',
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

class TitleNameBan extends StatelessWidget {
  const TitleNameBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 415, left: S.X_RATIO * 39.44),
      child: Text(
        '이름',
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

class TitleNickNameBan extends StatelessWidget {
  const TitleNickNameBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 495, left: S.X_RATIO * 39.44),
      child: Text(
        '닉네임',
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

class NickInputAndButton extends ConsumerStatefulWidget {
  const NickInputAndButton({super.key});

  @override
  _NickInputAndButtonState createState() => _NickInputAndButtonState();
}

class _NickInputAndButtonState extends ConsumerState<NickInputAndButton> {
  final TextEditingController _idController = TextEditingController();
  bool _isChecked = false;

  Future<void> _checkDuplicateNick() async {
    String enteredNick = _idController.text;

    try {
      final response = await http.post(
        Uri.parse('https://fineplay.kr/api/auth/check-nick-duplicate'), // 백엔드 API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickName': enteredNick}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'EXISTS') {
          // 아이디가 중복된 경우
          showDialog(
            context: context,
            builder: (BuildContext context) {
              S.init(context);

              return AlertDialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                backgroundColor: const Color(0xFF21213F),
                title: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 25 * S.Y_RATIO),
                      SizedBox(width: 8 * S.X_RATIO),
                      Text(
                        '중복 닉네임 제한',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20 * S.Y_RATIO,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '입력하신 닉네임은 이미 사용 중입니다.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * S.Y_RATIO,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '다른 닉네임으로 변경해 주세요!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * S.Y_RATIO,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: SizedBox(
                      width: 200 * S.X_RATIO,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          '변경하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16 * S.Y_RATIO,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          setState(() {
            _isChecked = false;
            ref.read(signInProvider.notifier).updateNickName(enteredNick);
          });
        } else {
          // 아이디가 중복되지 않은 경우
          setState(() {
            _isChecked = true;
            ref.read(signInProvider.notifier).updateNickName(enteredNick);
          });
        }
      } else {
        // 서버 오류 처리
        if (kDebugMode) {
          print('Failed to check Nick: ${response.statusCode}');
        }
      }
    } catch (e) {
      // 네트워크 오류 처리
      if (kDebugMode) {
        print('Error checking Nick: $e');
      }
    }
  }

  void _onNickChanged(String text) {
    ref.read(signInProvider.notifier).updateNickName(text);
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: S.Y_RATIO * 515, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _idController,
                  onChanged: _onNickChanged,
                  style: TextStyle(
                    color: const Color(0xFF616193),
                    fontSize: 12 * S.Y_RATIO,
                    fontFamily: 'Wanted Sans',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                  decoration: InputDecoration(
                    hintText: '닉네임 입력',
                    hintStyle: TextStyle(
                      color: const Color(0xFF616193),
                      fontSize: 12 * S.Y_RATIO,
                      fontFamily: 'Wanted Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14 * S.Y_RATIO, horizontal: 14 * S.X_RATIO),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF21213F), width: 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * S.X_RATIO),
              GestureDetector(
                onTap: _checkDuplicateNick,
                child: SvgPicture.asset('assets/ban/duplicate_button_ban.svg'),
              ),
            ],
          ),
        ),
        if (_isChecked)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: S.X_RATIO * 38, top: 3 * S.Y_RATIO),
              child: Text(
                '사용 가능한 닉네임입니다.',
                style: TextStyle(
                  color: Colors.green,
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
class TitleBirthBan extends StatelessWidget {
  const TitleBirthBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 586  , left: S.X_RATIO * 39.44),
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

class TitlePhoneBan extends StatelessWidget {
  const TitlePhoneBan({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 670, left: S.X_RATIO * 39.44),
      child: Text(
        '전화번호',
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

class TitlePosition extends StatelessWidget {
  const TitlePosition({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 840, left: S.X_RATIO * 39.47),
      child: Text(
        '포지션',
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

class PositionSelect extends ConsumerStatefulWidget {
  const PositionSelect({super.key});

  @override
  _PositionSelectState createState() => _PositionSelectState();
}

class _PositionSelectState extends ConsumerState<PositionSelect> {
  String? _selectedPosition;


  final List<String> _positions = ["MF", "DF", "FW"];


  void _onPositionChanged() {
    if (_selectedPosition != null ) {
      ref.read(signInProvider.notifier).updatePosition('$_selectedPosition');
    }
  }


  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 860, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPosition,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPosition = newValue;
                  _onPositionChanged();
                });
              },
              items: _positions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8 * S.Y_RATIO, horizontal: 6.5 * S.X_RATIO),
                filled: true,
                fillColor: const Color(0xFF21213F),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              hint: Text(
                '포지션',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              isExpanded: true,
            ),
          ),
          SizedBox(width: S.X_RATIO * 10),

        ],
      ),
    );
  }
}

// 전역 상태 관리를 위한 키와 함수
final GlobalKey<PhoneInputBanState> _phoneInputKey = GlobalKey<PhoneInputBanState>();





