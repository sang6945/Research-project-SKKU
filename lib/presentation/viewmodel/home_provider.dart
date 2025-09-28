// lib/viewmodel/home_provider.dart

import 'dart:convert';
import 'package:fineplay/presentation/viewmodel/token_provider.dart';
import 'package:fineplay/presentation/viewmodel/userId_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;


/// 홈 화면에 필요한 데이터 모델
class HomeData {
  final int status;
  final String userName;
  final String position;
  final String ovr;
  final String selectedStat;
  final String? profileImg;
  final String? currentTeam;
  final String? teamImg;
  final Map<String, dynamic> stats; // cro, fst, hed, ...
  final bool hasUnreadNotification;

  HomeData({
    required this.status,
    required this.userName,
    required this.position,
    required this.ovr,
    required this.selectedStat,
    this.profileImg,
    required this.currentTeam,
    this.teamImg,
    required this.stats,
    required this.hasUnreadNotification,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      status: json['status'] as int,
      userName: json['userName'] as String,
      position: json['position'] as String,
      ovr: json['ovr'] ?? '0',
      selectedStat: json['selectedStat'] as String,
      profileImg: json['profileImg'] as String?,
      currentTeam: json['currentTeam']?.toString() ?? '소속팀 없음',
      teamImg: json['teamImg'] as String?,
      hasUnreadNotification: json["hasUnreadNotification"] as bool? ?? false,
      stats: {
        'cro': json['cro'] ?? 0,
        'fst': json['fst'] ?? 0,
        'hed': json['hed'] ?? 0,
        'act': json['act'] ?? 0,
        'dri': json['dri'] ?? 0,
        'cop': json['cop'] ?? 0,
        'pas': json['pas'] ?? 0,
        'spd': json['spd'] ?? 0,
        'dec': json['dec'] ?? 0,
        'off': json['off'] ?? 0,
        'tac': json['tac'] ?? 0,
        'sho': json['sho'] ?? 0,
        'pac': json['pac'] ?? 0,
        'drv': json['drv'] ?? 0,
        'bld': json['bld'] ?? 0,
        'tec': json['tec'] ?? 0,
      },
    );
  }
}

/// userId를 인자로 받아 POST 요청을 보내고 HomeData를 반환하는 Provider
final homeProvider =
FutureProvider.family<HomeData, int>((ref, userId) async {
  final token  = ref.read(tokenProvider);
  final uri = Uri.parse('http://localhost:8080/api/home');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',},
    body: jsonEncode({'userId': userId}),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
    return HomeData.fromJson(body);
  } else {
    throw Exception('홈 데이터 불러오기 실패: ${response.statusCode}');
  }
});
