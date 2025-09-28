// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fineplay/utils/screen_ratio.dart';
import 'package:fineplay/presentation/viewmodel/setting_provider.dart';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileEditView extends ConsumerStatefulWidget {
  const ProfileEditView({super.key});

  @override
  ConsumerState<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends ConsumerState<ProfileEditView> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController realNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isDuplicate = false;
  bool _isDropdownOpen = false;
  bool _isInitialized = false;
  bool _isNicknameLength = false;

  final List<String> _positions = ["FW", "MF", "DF", "GK"];
  String _selectedPosition = "";

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  void _setChanged() {
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final token = ref.read(tokenProvider);
    Future.microtask(() => ref.read(settingProvider.notifier).loadEditProfile(token));

    nicknameController.addListener(_setChanged);
    emailController.addListener(_setChanged);
    birthdayController.addListener(_setChanged);
    realNameController.addListener(_setChanged);
    phoneController.addListener(_setChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = ref.watch(settingProvider.select((s) => s.profile));
    if (!_isInitialized && profile != null) {
      nicknameController.text = profile.nickname;
      emailController.text = profile.email;
      birthdayController.text = profile.birthday;
      realNameController.text = profile.realName;
      phoneController.text = profile.phoneNumber;
      _selectedPosition = profile.position;
      _isInitialized = true;
    }
  }

  Future<void> _editProfileWithJson({
    required String realName,
    required String nickName,
    required String phoneNumber,
    required String birth,
    required String position,
    required String token,
  }) async {
    final url = Uri.parse("http://localhost:8080/api/setting/AccountInfo/EditProfile");

    final body = {
      "realName": realName,
      "nickName": nickName,
      "phoneNumber": phoneNumber,
      "birth": birth,
      "position": position,
    };

    try {
      final response = await http.patch(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ 프로필 수정 성공');
      } else {
        debugPrint('❌ 실패: ${response.statusCode}');
        debugPrint('응답 본문: ${response.body}');
      }
    } catch (e) {
      debugPrint('🚨 네트워크 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    S.init(context);
    final settingState = ref.watch(settingProvider);
    final token = ref.watch(tokenProvider);
    final profile = settingState.profile;

    if (settingState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF030319),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF030319),
        body: Center(child: Text("프로필 정보를 불러올 수 없습니다.", style: TextStyle(color: Colors.white))),
      );
    }

    final isProfileChanged =
        _profileImage != null ||
            emailController.text.trim() != (profile.email) ||
            birthdayController.text.trim() != (profile.birthday) ||
            realNameController.text.trim() != (profile.realName) ||
            phoneController.text.trim() != (profile.phoneNumber) ||
            _selectedPosition != (profile.position);

    return Scaffold(
      backgroundColor: const Color(0xFF030319),
      appBar: AppBar(
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
        // 타이틀
        title: Padding(
          padding: EdgeInsets.only(top: 32 * S.Y_RATIO, left: 39 * S.X_RATIO),
          child: Text(
            "Fine Play",
            style: TextStyle(
              fontSize: 20 * S.Y_RATIO,
              fontFamily: 'GiantsInline',
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF7E1D),
            ),
          ),
        ),
        backgroundColor: const Color(0xFF030319),
        actions: const [], // 상단 아이콘 제거
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20 * S.X_RATIO),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30 * S.Y_RATIO),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100 * S.Y_RATIO,
                height: 100 * S.Y_RATIO,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20.0),
                  image: _profileImage != null
                      ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 50 * S.Y_RATIO, color: Colors.white30)
                    : null,
              ),
            ),
            SizedBox(height: 30 * S.Y_RATIO),
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('이메일'),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.grey, fontFamily: 'Wanted Sans'),
                            decoration: _buildInputDecoration(),
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * S.Y_RATIO),
                  ],
                );
              },
            ),
            _buildNicknameField(token, profile.nickname),
            _buildPositionDropdown(),
            SizedBox(height: 30 * S.Y_RATIO),
            GestureDetector(
              onTap: isProfileChanged || _isDuplicate
                  ? () async {
                await _editProfileWithJson(
                  realName: realNameController.text.trim(),
                  nickName: nicknameController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  birth: birthdayController.text.trim(),
                  position: _selectedPosition,
                  token: token,
                );
                if (mounted) {
                  Navigator.pop(context);
                }
              }
                  : null,
              child: Container(
                alignment: Alignment.center,
                height: 45 * S.Y_RATIO,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isProfileChanged || _isDuplicate && _isNicknameLength
                      ? const Color(0xFFFF7400)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: const Color(0xFFFF7400), width: 1),
                ),
                child: Text(
                  '변경 사항 저장',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15 * S.Y_RATIO,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ),
            ),
            SizedBox(height: 30 * S.Y_RATIO),
          ],
        ),
      ),
    );
  }


  String _duplicateMessage = '';
  Color _duplicateMessageColor = Colors.transparent;

  Widget _buildNicknameField(String token, String originalNickname) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("닉네임"),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: nicknameController,
                style: const TextStyle(color: Colors.white, fontFamily: 'Wanted Sans'),
                decoration: _buildInputDecoration(),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                final nickname = nicknameController.text.trim();
                final isChanged = nickname.isNotEmpty && nickname != originalNickname;
                if (!isChanged) return;

                final isDuplicate = await ref.read(settingProvider.notifier)
                    .checkNicknameDuplicate(nickname, token);

                _isDuplicate = isDuplicate;

                setState(() {
                  if (_isDuplicate) {
                    if (nickname.length <= 8) {
                      _isNicknameLength = true;
                      _duplicateMessage = '사용 가능한 닉네임입니다.';
                      _duplicateMessageColor = Colors.green;
                    } else {
                      _duplicateMessage = '닉네임은 8자 이하여야 합니다.';
                      _duplicateMessageColor = Colors.red;
                    }
                  } else {
                    _duplicateMessage = '중복된 닉네임입니다.';
                    _duplicateMessageColor = Colors.red;
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: 74 * S.X_RATIO,
                height: 44 * S.Y_RATIO,
                decoration: BoxDecoration(
                  color: (nicknameController.text.trim().isNotEmpty &&
                      nicknameController.text.trim() != originalNickname)
                      ? const Color(0xFFFF7400)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: const Color(0xFFFF7400), width: 1),
                ),
                child: Text(
                  '중복 확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13 * S.Y_RATIO,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10 * S.Y_RATIO),
        Text(
          _duplicateMessage,
          style: TextStyle(
            color: _duplicateMessageColor,
            fontSize: 14 * S.Y_RATIO,
            fontWeight: FontWeight.w600,
            fontFamily: 'Wanted Sans',
          ),
        ),
        SizedBox(height: 10 * S.Y_RATIO),
      ],
    );
  }

  Widget _buildPositionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("포지션"),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF21213F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
                child: Container(
                  height: 44 * S.Y_RATIO,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21213F),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(12),
                      bottom: _isDropdownOpen ? Radius.zero : const Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedPosition,
                        style: TextStyle(
                          color: _selectedPosition == 'FW'
                              ? const Color(0xFFFF381E)  // Red for FW
                              : _selectedPosition == 'MF'
                              ? const Color(0xFF00D68F)  // Green for MF
                              : _selectedPosition == 'DF'
                              ? const Color(0xFF5650FF)  // Blue for DF
                              : Colors.white,      // Default white for others
                          fontSize: 14 * S.Y_RATIO,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Wanted Sans',
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/ban/Polygon 8.svg',
                        // ignore: deprecated_member_use
                        color: _isDropdownOpen ? const Color(0xFFFF7400) : const Color(0xFF616193),
                        height: 14 * S.Y_RATIO,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isDropdownOpen)
                Container(
                  height: 150 * S.Y_RATIO,
                  decoration: const BoxDecoration(
                    color: Color(0xFF21213F),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _positions.length,
                    itemBuilder: (context, index) {
                      final position = _positions[index];
                      final isSelected = _selectedPosition == position;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPosition = position;
                            _isDropdownOpen = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF7400) : const Color(0xFF21213F),
                            borderRadius: isSelected ? BorderRadius.circular(12) : BorderRadius.zero,
                          ),
                          child: Text(
                            position,
                            style: TextStyle(
                              color: position == 'FW'
                                  ? const Color(0xFFFF381E)  // Red for FW
                                  : position == 'MF'
                                  ? const Color(0xFF00D68F)  // Green for MF
                                  : position == 'DF'
                                  ? const Color(0xFF5650FF)  // Blue for DF
                                  : Colors.white,      // Default white for others
                              fontSize: 14 * S.Y_RATIO,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
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
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration({bool disabled = false}) {
    return InputDecoration(
      filled: true,
      fillColor: disabled ? Colors.white10 : const Color(0xFF21213F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
