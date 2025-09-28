import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

/// API Base URL (환경에 따라 변경 필요)
const String baseUrl = "http://localhost:8080/api/mypage";

class MyTeam {
  final int? teamId;
  final String? teamName;

  MyTeam({
    required this.teamId,
    required this.teamName,
  });

  factory MyTeam.fromJson(Map<String, dynamic> json) {
    return MyTeam(
      teamId: json['teamId'] as int?,
      teamName: json['teamName'] as String?,
    );
  }
}

/// 마이페이지 프로필 모델
class MypageProfile {
  final int status;
  final String userName;
  final String position;
  final String ovr;
  final String ovrPercent;

  /// 최대 3개의 팀(팀이 부족하면 null 세트로 채움)
  final List<MyTeam> teams;

  final String selectedStat;
  final Map<String, dynamic> stats;
  final Map<String, String> statImages;
  final String profileImg;
   final bool hasUnreadNotification;

  MypageProfile({
    required this.status,
    required this.userName,
    required this.position,
    required this.ovr,
    required this.ovrPercent,
    required this.teams,
    required this.selectedStat,
    required this.stats,
    required this.statImages,
    required this.profileImg,
    required this.hasUnreadNotification,
  });

  factory MypageProfile.fromJson(Map<String, dynamic> json) {
    final raw = json['teams'] as List<dynamic>? ?? [];
    final parsedTeams = raw
        .map((e) => MyTeam.fromJson(e as Map<String, dynamic>))
        .toList();

    return MypageProfile(
      status: json["status"],
      userName: json["userName"],
      position: json["position"],

      ovr: json["ovr"],
      ovrPercent: json["ovrPercent"],
      teams: parsedTeams,
      selectedStat: json["selectedStat"]?? "",
      stats: {
        "CRO": json["cro"]?? 0,
        "HED": json["hed"]?? 0,
        "FST": json["fst"]?? 0,
        "ACT": json["act"]?? 0,
        "OFF": json["off"]?? 0,
        "TEC": json["tec"]?? 0,
        "COP": json["cop"]?? 0,
        "PAC": json["pac"]?? 0,
        "PAS": json["pas"]?? 0,
        "SPD": json["spd"]?? 0,
        "SHO": json["sho"]?? 0,
        "DRV": json["drv"]?? 0,
        "DEC": json["dec"]?? 0,
        "DRI": json["dri"]?? 0,
        "TAC": json["tac"]?? 0,
        "BLD": json["bld"]?? 0,
      },
      statImages: {
        "CROImg": json["croimg"]?? "",
        "HEDImg": json["hedimg"]?? "",
        "FSTImg": json["fstimg"]?? "",
        "ACTImg": json["actimg"]?? "",
        "OFFImg": json["offimg"]?? "",
        "TECImg": json["tecimg"]?? "",
        "COPImg": json["copimg"]?? "",
      },
      profileImg: json["profileImg"] ?? "",
       hasUnreadNotification: json["hasUnreadNotification"] as bool? ?? false,
    );
  }
}

/// 페이지 이동 API 결과용 DTO
class PageMoveResult {
  final String img;
  final bool hasUnreadNotification;

  PageMoveResult({
    required this.img,
    required this.hasUnreadNotification,
  });

  factory PageMoveResult.fromJson(Map<String, dynamic> json) {
    return PageMoveResult(
      img: json['img'] as String,
      hasUnreadNotification: json['hasUnreadNotification'] as bool,
    );
  }
}
/// 마이페이지 서비스 클래스
class MypageService {
  final String authToken;

  MypageService({required this.authToken});

  /// **마이페이지 프로필 조회**
  Future<MypageProfile> getMypageProfile(int userId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken"
      },
      body: jsonEncode({"userId": userId}),
    );

    if (response.statusCode == 200) {
      return MypageProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("마이페이지 조회 실패: ${response.body}");
    }
  }

  /// **선택된 스탯 업데이트**
  Future<void> updateSelectedStat(int userId, String selectedStat) async {
    final response = await http.post(
      Uri.parse("$baseUrl/selectedstat"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken"
      },
      body: jsonEncode({
        "userId": userId,
        "selectedStat": selectedStat,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("스탯 업데이트 실패: ${response.body}");
    }
  }

  /// **스탯 상세 페이지 이동**
  Future<PageMoveResult> movePage(String statName, int userId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/page/$statName"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: jsonEncode({"userId": userId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return PageMoveResult.fromJson(body);
    } else {
      throw Exception("스탯 페이지 이동 실패: ${response.body}");
    }
  }
}

/// **마이페이지 상태 관리**
final mypageProvider = FutureProvider.family<MypageProfile, Tuple2<int, String>>((ref, params) {
  final userId = params.item1;
  final authToken = params.item2;
  final service = MypageService(authToken: authToken);
  return service.getMypageProfile(userId);
});

final pageMoveProvider = FutureProvider.family<PageMoveResult, Tuple3<String, int, String>>((ref, params) {
  final feature = params.item1;
  final userId = params.item2;
  final token = params.item3;
  final service = MypageService(authToken: token);
  return service.movePage(feature, userId);
});