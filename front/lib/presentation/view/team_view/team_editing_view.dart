// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously
//team_editing_view.dart
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import '../../viewmodel/team_editing_provider.dart'; // team_making_provider.dart 경로에 맞게 수정
import 'dart:io';
import 'package:image_picker/image_picker.dart';



class TeamEditing_view extends ConsumerStatefulWidget {
  final int teamId;

  const TeamEditing_view({required this.teamId, super.key});

  @override
  ConsumerState<TeamEditing_view> createState() => _TeamEditingViewState();
}
class _TeamEditingViewState extends ConsumerState<TeamEditing_view> {
  @override
  void initState() {
    super.initState();
    final token = ref.read(tokenProvider);
    final userId = ref.read(userIdProvider)!;
    ref
        .read(teamEditingProvider(widget.teamId).notifier)
        .loadTeam(token: token, userId: userId);
  }

  Future<void> saveTeam() async {
    final token = ref.read(tokenProvider);
    try {
      await ref.read(teamEditingProvider(widget.teamId).notifier).updateTeam(token);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("팀 정보 수정 성공")));
      Navigator.pop(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            backgroundColor: const Color(0xFF21213D),
            title: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8 * S.X_RATIO),
                ],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '팀 만들기는 가입된 팀이',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * S.Y_RATIO,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                Text(
                  '2팀 이하일 때만 가능해요.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * S.Y_RATIO,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Wanted Sans',
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
                      '확인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * S.Y_RATIO,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Wanted Sans',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return WillPopScope(
      onWillPop: () async {
        ref.read(teamEditingProvider(widget.teamId).notifier).reset();
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      BackButtonBan(onPressed: () {
                        ref
                            .read(teamEditingProvider(widget.teamId).notifier)
                            .reset();
                        Navigator.pop(context);
                      }),
                      const TeamPhoto(),
                      const PageName(),
                      const TitleTeamName(),
                      TeamInputAndButton(teamId: widget.teamId),
                      const TitleHometown(),
                      HometownDropdown(teamId: widget.teamId),
                    ],
                  ),
                ],
              ),
              TeamSaveButton(
                teamId: widget.teamId,
                onPressed: saveTeam, // 외부에서 처리되는 로직을 전달
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BackButtonBan extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonBan({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(
          top: S.Y_RATIO * 38.76,
          left: S.X_RATIO * 30,
          right: S.X_RATIO * 318.27,
        ),
        child: SvgPicture.asset('assets/ban/back_icon_ban.svg'),
      ),
    );
  }
}

class TeamPhoto extends StatefulWidget {
  const TeamPhoto({super.key});

  @override
  _TeamPhotoState createState() => _TeamPhotoState();
}

class _TeamPhotoState extends State<TeamPhoto> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (picked != null) {
      setState(() {
        _image = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return GestureDetector(
      onTap: _pickImage,
      child: Center(
        child: Container(
          margin: EdgeInsets.only(top: S.Y_RATIO * 88),
          alignment: Alignment.topCenter,
          width: 72 * S.Y_RATIO,
          height: 72 * S.Y_RATIO,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            image: _image != null
                ? DecorationImage(
              image: FileImage(File(_image!.path)),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: _image == null
              ? Center(
            child: Icon(
              Icons.camera_enhance,
              size: 24 * S.Y_RATIO,
              color: Colors.grey,
            ),
          )
              : null,
        ),
      ),
    );
  }
}

class PageName extends StatelessWidget {
  const PageName({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 43),
      alignment: Alignment.topCenter,
      child: Text(
        '팀 정보 수정',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18 * S.Y_RATIO,
          fontFamily: 'Wanted Sans',
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class TitleTeamName extends StatelessWidget {
  const TitleTeamName({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 182, left: S.X_RATIO * 41),
      child: Text(
        '팀 이름 (변경 시에만 입력해주세요!)',
        style: TextStyle(
          color: const Color(0xFFC1C1C1),
          fontSize: 12 * S.Y_RATIO,
          fontFamily: 'Wanted Sans',
          fontWeight: FontWeight.w700,
          height: 0,
        ),
      ),
    );
  }
}

/// 팀 이름 입력 및 중복 확인 위젯
/// 팀 이름 입력 및 중복 확인 위젯
class TeamInputAndButton extends ConsumerStatefulWidget {
  final int teamId;

  const TeamInputAndButton({required this.teamId, super.key});

  @override
  _TeamInputAndButtonState createState() => _TeamInputAndButtonState();
}

class _TeamInputAndButtonState extends ConsumerState<TeamInputAndButton> {
  late final TextEditingController _controller;
  bool _formatError = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(teamEditingProvider(widget.teamId));
    _controller = TextEditingController(text: state.teamName);
  }

  Future<void> _checkDuplicate() async {
    final name = _controller.text.trim();
    // 1) 포맷 검사
    if (name.isEmpty || !_isValidTeamName(name)) {
      setState(() => _formatError = true);
      return;
    }
    setState(() => _formatError = false);

    // 2) provider 중복 검사 호출
    final token = ref.read(tokenProvider);
    await ref
        .read(teamEditingProvider(widget.teamId).notifier)
        .checkDuplicate(token);
    final isValid = ref.read(teamEditingProvider(widget.teamId)).isNameValid;
    if (!isValid) {
      _showDuplicateDialog();
    }
  }

  void _showDuplicateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  '중복 팀 이름 제한',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20 * S.Y_RATIO,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '입력하신 팀 이름은 이미 사용 중입니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * S.Y_RATIO,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Wanted Sans',
                ),
              ),
              SizedBox(height: 5 * S.Y_RATIO),
              Text(
                '다른 팀 이름으로 변경해 주세요!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * S.Y_RATIO,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Wanted Sans',
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
                      fontFamily: 'Wanted Sans',
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
  }

  bool _isValidTeamName(String name) {
    final regex = RegExp(r'^[가-힣a-zA-Z0-9]{1,8}$');
    return regex.hasMatch(name);
  }

  @override
  @override
  Widget build(BuildContext context) {
    // provider 상태를 구독
    final teamState = ref.watch(teamEditingProvider(widget.teamId));

    // 초기 로드 완료 시 controller.text 에 반영
    ref.listen<TeamEditingState>(
      teamEditingProvider(widget.teamId),
          (previous, next) {
        // controller 가 아직 빈 문자열이고,
        // provider 쪽에 teamName 이 들어왔다면
        if (_controller.text.isEmpty && next.teamName.isNotEmpty) {
          _controller.text = next.teamName;
          // 커서 맨 끝으로 보내기
          _controller.selection = TextSelection.collapsed(
            offset: _controller.text.length,
          );
        }
      },
    );
    final inputName = _controller.text.trim();
    final hasChanged = inputName.isNotEmpty && inputName != teamState.originalName;


    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: S.Y_RATIO * 200, left: S.X_RATIO * 30, right: S.X_RATIO * 30),
          child:   Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  readOnly: teamState.isNameChecked,
                  onChanged: (v) {
                    // 이름이 바뀌면 provider에도 update
                    ref
                        .read(teamEditingProvider(widget.teamId).notifier)
                        .updateName(v);
                    // 포맷 오류 메시지 사라지게
                    setState(() => _formatError = false);
                  },
                  decoration: InputDecoration(
                    hintText: '팀 이름 입력',
                    filled: true,
                    fillColor: const Color(0xFF21213F),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF3D3D91), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF21213F)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 12 * S.Y_RATIO, fontFamily: 'Wanted Sans',
                  ),
                ),
              ),
              SizedBox(width: 10 * S.X_RATIO),
              // 변경된 이름이고, 아직 중복 체크되지 않았으면 버튼 표시
              if (hasChanged && !teamState.isNameChecked)
                GestureDetector(
                  onTap: _checkDuplicate,
                  child: SvgPicture.asset('assets/ban/duplicate_button_ban.svg'),
                )

              else
                Container(
                  width: 74 * S.X_RATIO,
                  height: 44 * S.Y_RATIO,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFBCBCBC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Center(
                    child: Text(
                      '중복 확인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * S.Y_RATIO,
                        fontFamily: 'Wanted Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if(!hasChanged&&teamState.isNameValid)
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(left: 38 * S.X_RATIO, top: 3 * S.Y_RATIO),
            child: Text(
              '기존 팀 이름과 동일합니다.',
              style: TextStyle(
                color: Colors.green,
                fontSize: 9 * S.Y_RATIO,
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        if (!teamState.isNameValid)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 38 * S.X_RATIO, top: 3 * S.Y_RATIO),
              child: Text(
    teamState.message,
    style: TextStyle(color: const Color(0xFFEF2525), fontSize: 9 * S.Y_RATIO, fontFamily: 'Wanted Sans',
    fontWeight: FontWeight.w400,),

                ),
              ),
            ),

        if (teamState.isNameValid&&teamState.isNameChecked)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 38 * S.X_RATIO, top: 3 * S.Y_RATIO),
              child:Text(
                '사용 가능한 이름입니다.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 9 * S.Y_RATIO,
                  fontFamily: 'Wanted Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        if (_formatError)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 38 * S.X_RATIO, top: 3 * S.Y_RATIO),
              child: Text(
                '팀 이름은 8글자 이내로 국문, 영문, 숫자만 입력 가능합니다.',
                style: TextStyle(
                  color: const Color(0xFFEF2525),
                  fontSize: 9 * S.Y_RATIO,
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





class TitleHometown extends StatelessWidget {
  const TitleHometown({super.key});

  @override
  Widget build(BuildContext context) {
    S.init(context);
    return Container(
      margin: EdgeInsets.only(top: S.Y_RATIO * 279, left: S.X_RATIO * 41),
      child: Text(
        '연고지',
        style: TextStyle(
          color: const Color(0xFFC1C1C1),
          fontSize: 12 * S.Y_RATIO,
          fontFamily: 'Wanted Sans',
          fontWeight: FontWeight.w700,
          height: 0,
        ),
      ),
    );
  }
}

/// 연고지 드롭다운 위젯
class HometownDropdown extends ConsumerStatefulWidget {
  final int teamId;

  const HometownDropdown({required this.teamId, super.key});

  @override
  _HometownDropdownState createState() => _HometownDropdownState();
}

class _HometownDropdownState extends ConsumerState<HometownDropdown> {
  bool _isHometownDropdownOpen = false;
  bool _isDistrictDropdownOpen = false;
  String _selectedHometown = '';
  String _selectedDistrict = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // ③ 초기 연고지(시/도, 군/구)를 Provider에서 세팅
  }

  void _onHometownSelected(String selected) {
    setState(() {
      _selectedHometown = selected;
      _selectedDistrict = " ";
      _isHometownDropdownOpen = false;
      _isDistrictDropdownOpen = true;
    });
    ref
        .read(teamEditingProvider(widget.teamId).notifier)
        .updateHometown1(selected);
  }

  final Map<String, List<String>> _districts = {
    "서울": [
      "강남구",
      "강동구",
      "강북구",
      "강서구",
      "관악구",
      "광진구",
      "구로구",
      "금천구",
      "노원구",
      "도봉구",
      "동대문구",
      "동작구",
      "마포구",
      "서대문구",
      "서초구",
      "성동구",
      "성북구",
      "송파구",
      "양천구",
      "영등포구",
      "용산구",
      "은평구",
      "종로구",
      "중구",
      "중랑구"
    ],
    "부산": [
      "강서구",
      "금정구",
      "기장군",
      "남구",
      "동구",
      "동래구",
      "부산진구",
      "북구",
      "사상구",
      "사하구",
      "서구",
      "수영구",
      "연제구",
      "영도구",
      "중구",
      "해운대구"
    ],
    "대구": ["남구", "달서구", "달성군", "동구", "북구", "서구", "수성구", "중구"],
    "인천": ["강화군", "계양구", "남동구", "동구", "미추홀구", "부평구", "서구", "연수구", "옹진군", "중구"],
    "광주": ["광산구", "남구", "동구", "북구", "서구"],
    "대전": ["대덕구", "동구", "서구", "유성구", "중구"],
    "울산": ["남구", "동구", "북구", "울주군", "중구"],
    "세종": ["금남면", "부강면", "소정면", "연기면", "연동면", "전동면", "전의면", "조치원읍"],
    "경기": [
      "가평군",
      "고양시",
      "과천시",
      "광명시",
      "광주시",
      "구리시",
      "군포시",
      "김포시",
      "남양주시",
      "동두천시",
      "부천시",
      "성남시",
      "수원시",
      "시흥시",
      "안산시",
      "안성시",
      "안양시",
      "양주시",
      "양평군",
      "여주시",
      "연천군",
      "오산시",
      "용인시",
      "의왕시",
      "의정부시",
      "이천시",
      "파주시",
      "평택시",
      "포천시",
      "하남시",
      "화성시"
    ],
    "강원": [
      "강릉시",
      "고성군",
      "동해시",
      "삼척시",
      "속초시",
      "양구군",
      "양양군",
      "영월군",
      "원주시",
      "인제군",
      "정선군",
      "철원군",
      "춘천시",
      "태백시",
      "평창군",
      "홍천군",
      "횡성군"
    ],
    "충북": [
      "괴산군",
      "단양군",
      "보은군",
      "영동군",
      "옥천군",
      "음성군",
      "제천시",
      "증평군",
      "진천군",
      "청주시",
      "충주시"
    ],
    "충남": [
      "계룡시",
      "공주시",
      "논산시",
      "당진시",
      "보령시",
      "부여군",
      "서산시",
      "서천군",
      "아산시",
      "예산군",
      "천안시",
      "청양군",
      "태안군",
      "홍성군"
    ],
    "전북": [
      "고창군",
      "군산시",
      "김제시",
      "남원시",
      "무주군",
      "부안군",
      "순창군",
      "완주군",
      "익산시",
      "임실군",
      "장수군",
      "전주시",
      "정읍시",
      "진안군"
    ],
    "전남": [
      "강진군",
      "고흥군",
      "곡성군",
      "광양시",
      "구례군",
      "나주시",
      "담양군",
      "목포시",
      "무안군",
      "보성군",
      "순천시",
      "신안군",
      "여수시",
      "영광군",
      "영암군",
      "완도군",
      "장성군",
      "장흥군",
      "진도군",
      "해남군",
      "화순군"
    ],
    "경북": [
      "경산시",
      "경주시",
      "고령군",
      "구미시",
      "군위군",
      "김천시",
      "문경시",
      "봉화군",
      "상주시",
      "성주군",
      "안동시",
      "영덕군",
      "영양군",
      "영주시",
      "영천시",
      "예천군",
      "울릉군",
      "울진군",
      "의성군",
      "청도군",
      "청송군",
      "포항시"
    ],
    "경남": [
      "거제시",
      "거창군",
      "고성군",
      "김해시",
      "남해군",
      "밀양시",
      "사천시",
      "산청군",
      "양산시",
      "의령군",
      "진주시",
      "창녕군",
      "창원시",
      "통영시",
      "하동군",
      "함안군",
      "함양군",
      "합천군"
    ],
    "제주": ["서귀포시", "제주시"]
  };

  void _onDistrictSelected(String selected) {
    setState(() {
      _selectedDistrict = selected;
      _isDistrictDropdownOpen = false;
    });
    ref
        .read(teamEditingProvider(widget.teamId).notifier)
        .updateHometown2(selected);
  }


  @override
  Widget build(BuildContext context) {
    S.init(context);
    final teamState = ref.watch(teamEditingProvider(widget.teamId));
    if (!_initialized && teamState.homeTown1.isNotEmpty) {
      _selectedHometown = teamState.homeTown1;
      _selectedDistrict = teamState.homeTown2;
      _initialized = true;
    }

    return Padding(
      padding: EdgeInsets.only(top: 297 * S.Y_RATIO),
      child: Center(
        child: Container(
          width: 300 * S.X_RATIO,
          decoration: BoxDecoration(
            color: const Color(0xFF21213F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isHometownDropdownOpen = !_isHometownDropdownOpen;
                    _isDistrictDropdownOpen = false;
                  });
                },
                child: Container(
                  height: 44 * S.Y_RATIO,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21213F),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(12),
                      bottom:
                      (_isHometownDropdownOpen || _isDistrictDropdownOpen)
                          ? Radius.zero
                          : const Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$_selectedHometown $_selectedDistrict",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * S.Y_RATIO,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Wanted Sans',
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/ban/Polygon 8.svg',
                        color:
                        (_isHometownDropdownOpen || _isDistrictDropdownOpen)
                            ? const Color(0xFFFF7400)
                            : const Color(0xFF616193),
                        height: 14 * S.Y_RATIO,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isHometownDropdownOpen)
                Column(
                  children: [
                    Container(
                      width: 300 * S.X_RATIO,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21213F),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 3),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        "시 / 도 선택",
                        style: TextStyle(
                          color: const Color(0xFFBCBCBC),
                          fontSize: 12 * S.Y_RATIO,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Wanted Sans',
                        ),
                      ),
                    ),
                    Container(
                      height: 200 * S.Y_RATIO,
                      decoration: const BoxDecoration(
                        color: Color(0xFF21213F),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _districts.keys.length,
                        itemBuilder: (context, index) {
                          final hometown = _districts.keys.elementAt(index);
                          return GestureDetector(
                            onTap: () => _onHometownSelected(hometown),
                            child: Container(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedHometown == hometown
                                    ? const Color(0xFFFF7400)
                                    : const Color(0xFF21213F),
                                borderRadius: _selectedHometown == hometown
                                    ? BorderRadius.circular(12)
                                    : BorderRadius.zero,
                              ),
                              child: Text(
                                hometown,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: _selectedHometown == hometown
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  fontFamily: 'Wanted Sans',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              if (_isDistrictDropdownOpen &&
                  _districts.containsKey(_selectedHometown))
                Column(
                  children: [
                    Container(
                      width: 300 * S.X_RATIO,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21213F),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 3),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        "군 / 구 선택",
                        style: TextStyle(
                          color: const Color(0xFFBCBCBC),
                          fontSize: 12 * S.Y_RATIO,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Wanted Sans',
                        ),
                      ),
                    ),
                    Container(
                      height: 200 * S.Y_RATIO,
                      decoration: const BoxDecoration(
                        color: Color(0xFF21213F),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _districts[_selectedHometown]!.length,
                        itemBuilder: (context, index) {
                          final district =
                          _districts[_selectedHometown]![index];
                          return GestureDetector(
                            onTap: () => _onDistrictSelected(district),
                            child: Container(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedDistrict == district
                                    ? const Color(0xFFFF7400)
                                    : const Color(0xFF21213F),
                                borderRadius: _selectedDistrict == district
                                    ? BorderRadius.circular(12)
                                    : BorderRadius.zero,
                              ),
                              child: Text(
                                district,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14 * S.Y_RATIO,
                                  fontWeight: _selectedDistrict == district
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  fontFamily: 'Wanted Sans',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 팀 만들기 버튼: provider 내 createTeam 메서드를 호출하여 API 통신
/// 팀 저장 버튼: 중복 확인 후에만 활성화
class TeamSaveButton extends ConsumerStatefulWidget {
  final int teamId;
  final VoidCallback onPressed;

  const TeamSaveButton({required this.teamId, required this.onPressed, super.key});

  @override
  _TeamSaveButtonState createState() => _TeamSaveButtonState();
}

class _TeamSaveButtonState extends ConsumerState<TeamSaveButton> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamEditingProvider(widget.teamId));
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamEditingProvider(widget.teamId));

    final nameChanged = teamState.teamName.isNotEmpty
        && teamState.teamName != teamState.originalName;

    final hometownValid =
        teamState.homeTown1.isNotEmpty &&
            teamState.homeTown2.isNotEmpty;

    final nameNotEmpty = teamState.teamName.isNotEmpty;

    final canSave = nameNotEmpty && hometownValid && (!nameChanged || teamState.isNameChecked);

    return Container(
      margin: EdgeInsets.only(
          top: 710 * S.Y_RATIO, left: 36 * S.X_RATIO, right: 36 * S.X_RATIO),
      child: InkWell(
        onTap: canSave ? widget.onPressed : null,
        child: Ink(
          decoration: BoxDecoration(
            color: canSave ? const Color(0xFFFF7400) : Colors.transparent,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: const Color(0xFFFF7400), width: 1),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 45 * S.Y_RATIO,
            width: double.infinity,
            child: Text(
              '변경 사항 저장',
              style: TextStyle(
                color: canSave ? Colors.white : const Color(0xFFBCBCBC),
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

