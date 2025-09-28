import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


/// API Base URL (환경에 따라 변경 필요)
const String baseUrl = "http://localhost:8080/api/teamInfo";

/// FlutterSecureStorage 인스턴스
const _secureStorage = FlutterSecureStorage();

/// 단일 매치 결과 DTO
class MatchResult {
  final String date;
  final String result;
  final String homeScore;
  final String homeTeam;
  final String awayScore;
  final String awayTeam;
  final String matchId;

  MatchResult({
    required this.date,
    required this.result,
    required this.homeScore,
    required this.homeTeam,
    required this.awayScore,
    required this.awayTeam,
    required this.matchId,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      date: json['date'] as String,
      result: json['result'] as String,
      homeScore: json['homeScore'] as String,
      homeTeam: json['hometeam'] as String,
      awayScore: json['awayScore'] as String,
      awayTeam: json['awayteam'] as String,
      matchId: json['matchId'] as String,
    );
  }
}

/// 1) 구간별 분포 DTO
class StatDistribution {
  final String range;
  final int fwCount;
  final int mfCount;
  final int dfCount;

  StatDistribution({
    required this.range,
    required this.fwCount,
    required this.mfCount,
    required this.dfCount,
  });

  factory StatDistribution.fromJson(Map<String, dynamic> json) {
    return StatDistribution(
      range: json['range'] as String,
      fwCount: json['fwCount'] as int,
      mfCount: json['mfCount'] as int,
      dfCount: json['dfCount'] as int,
    );
  }
}

/// 팀 정보 전체 DTO
class TeamInfo {
  final int statusCode;
  final String responseMessage;
  final String teamName;
  final String ovr;
  final String ovrPercent;
  final String homeTown;
  final String memberNum;
  final String sports;
  final String teamRegister;
  final String teamImg;
  final String ovrDist;
  final String fw;
  final String df;
  final String mf;
  final String pac;
  final String spd;
  final String pas;
  final String recentWin15;
  final String recentDraw15;
  final String recentLose15;
  final String totalWin;
  final String totalDraw;
  final String totalLose;
  final String winningRate;
  final List<MatchResult> matchResultList;
  final List<StatDistribution> statDistribution;


  TeamInfo({
    required this.statusCode,
    required this.responseMessage,
    required this.teamName,
    required this.ovr,
    required this.ovrPercent,
    required this.teamImg,
    required this.homeTown,
    required this.memberNum,
    required this.sports,
    required this.teamRegister,
    required this.ovrDist,
    required this.fw,
    required this.df,
    required this.mf,
    required this.pac,
    required this.spd,
    required this.pas,
    required this.recentWin15,
    required this.recentDraw15,
    required this.recentLose15,
    required this.totalWin,
    required this.totalDraw,
    required this.totalLose,
    required this.winningRate,
    required this.matchResultList,
    required this.statDistribution,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    // spec 상 응답 바디가 최상위에 바로 fields 와 MatchResult_List 를 노출
    // MatchResult_List가 null이면 빈 리스트로
    final rawList = json['matchResultList'] as List<dynamic>? ?? <dynamic>[];
    final list = rawList
        .map((e) => MatchResult.fromJson(e as Map<String,dynamic>))
        .toList();

    // 2) statDistribution 파싱
    final rawDist = json['statDistribution'] as List<dynamic>? ?? [];
    final dist = rawDist
        .map((e) => StatDistribution.fromJson(e as Map<String, dynamic>))
        .toList();

    return TeamInfo(
      statusCode: json['status'] as int,
      responseMessage: json['responseMessage'] as String,
      teamName: json['teamName'] as String,
      ovr: json['ovr']?? "0",
      ovrPercent: json['ovrPercent']?? "0",
      homeTown: json['homeTown']?? "",
      memberNum: json['memberNum']?? "",
      sports: json['sports'] as String,
      teamRegister: json['teamRegister'] as String,
      ovrDist: json['OVR_dist']?? "",
      teamImg: json['teamImg']?? "",
      fw: json['fw']?? "0",
      df: json['df']?? "0",
      mf: json['mf']?? "0",
      pac: json['pac']?? "0",
      spd: json['spd']?? "0",
      pas: json['pas']?? "0",
      recentWin15: json['recentWin15'] as String,
      recentDraw15: json['recentDraw15'] as String,
      recentLose15: json['recentLose15'] as String,
      totalWin: json['totalWin'] as String,
      totalDraw: json['totalDraw'] as String,
      totalLose: json['totalLose'] as String,
      winningRate: json['winningRate'] as String,
      matchResultList: list,
      statDistribution: dist,
    );
  }
}

/// 매치 상세 정보 DTO
class MatchDetail {
  final int statusCode;
  final String responseMessage;
  final String location;
  final String? position;
  final int act, cro, fst, off, hed, tec, sho, cop, drv, bld, dri, spd, dec, pac, pas, tac;
  final String hometeamScore,awayteamScore,assist, score, selectedStat, grade, homeTeam, awayTeam, matchDate, playTime;
  final String formation;
  final List<Scorer> homeTeamScorer;
  final List<Scorer> awayTeamScorer;

  MatchDetail({
    required this.statusCode,
    required this.responseMessage,
    required this.location,
    this.position,
    required this.act,
    required this.cro,
    required this.fst,
    required this.off,
    required this.hed,
    required this.tec,
    required this.sho,
    required this.cop,
    required this.drv,
    required this.bld,
    required this.dri,
    required this.hometeamScore,
    required this.awayteamScore,
    required this.spd,
    required this.dec,
    required this.pac,
    required this.pas,
    required this.tac,
    required this.assist,
    required this.score,
    required this.selectedStat,
    required this.grade,
    required this.homeTeam,
    required this.awayTeam,
    required this.formation,
    required this.matchDate,
    required this.playTime,
    required this.homeTeamScorer,
    required this.awayTeamScorer,
  });

  factory MatchDetail.fromJson(Map<String, dynamic> json) {
    List<Scorer> parseScorers(List<dynamic>? raw) => raw
        ?.map((e) => Scorer.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return MatchDetail(
      statusCode: json['statusCode'] as int,
      responseMessage: json['responseMessage'] as String,
      location: json['location'] ?? "-",
      position: json['position']?? "-",
      hometeamScore: json['homeTeamScore']?? "0",
      awayteamScore: json['awayTeamScore']?? "0",
      act: json['act'] as int,
      cro: json['cro'] as int,
      fst: json['fst'] as int,
      off: json['off'] as int,
      hed: json['hed'] as int,
      tec: json['tec'] as int,
      sho: json['sho'] as int,
      cop: json['cop'] as int,
      drv: json['drv'] as int,
      bld: json['bld'] as int,
      dri: json['dri'] as int,
      spd: json['spd'] as int,
      dec: json['dec'] as int,
      pac: json['pac'] as int,
      pas: json['pas'] as int,
      tac: json['tac'] as int,
      assist: json['assist'] as String,
      score: json['score'] as String,
      selectedStat: json['selectedStat'] as String,
      grade: json['grade'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      formation: json['formation'] ?? "",
      matchDate: json['match_Date'] as String,
      playTime: json['playTime'] as String,
      homeTeamScorer: parseScorers(json['homeTeam_Scorer'] as List<dynamic>?),
      awayTeamScorer: parseScorers(json['awayTeam_Scorer'] as List<dynamic>?),
    );
  }
}

/// 득점자 DTO
class Scorer {
  final String time;
  final String player;
  Scorer({ required this.time, required this.player });
  factory Scorer.fromJson(Map<String,dynamic> json) => Scorer(
    time: json['time'] as String,
    player: json['player'] as String,
  );
}


class MatchStats {
  final String homeTeamName;
  final String awayTeamName;
  final Map<String, String> home;
  final Map<String, String> away;

  MatchStats({
    required this.homeTeamName,
    required this.awayTeamName,
    required this.home,
    required this.away,
  });

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    return MatchStats(
      homeTeamName: json['homeTeamName'] as String,
      awayTeamName: json['awayTeamName'] as String,
      home: Map<String, String>.from(json['home'] as Map),
      away: Map<String, String>.from(json['away'] as Map),
    );
  }
}


/// 팀 정보 API 서비스
class TeamInfoService {
  /// teamInfo 불러오기
  final String token;
  TeamInfoService({ required this.token });

  Future<TeamInfo> fetchTeamInfo({
    required int userId,
    required int teamId,
  }) async {
    // 1) 저장된 토큰 꺼내기
    /*final token = await _secureStorage.read(key: 'authToken');
    if (token == null) {
      throw Exception('로그인 정보가 없습니다.');
    }*/

    // 2) POST 요청
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'userId': userId,
        'teamId': teamId,
      }),
    );

    // 3) 응답 처리
    if (resp.statusCode == 200) {
      final body = json.decode(resp.body) as Map<String, dynamic>;
      return TeamInfo.fromJson(body);
    } else {
      final err = json.decode(resp.body);
      throw Exception('팀 정보 페이지 이동 실패: ${err['responseMessage'] ?? resp.body}');

    }
  }

  ///전체 경기결과
  Future<List<MatchResult>> fetchAllMatches({ required int teamId }) async {
    final resp = await http.post(
      Uri.parse("$baseUrl/AllMatch"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({ 'teamId': teamId }),
    );

    if (resp.statusCode == 200) {
      // 1) 전체 응답을 Map<String,dynamic>으로 파싱
      final Map<String, dynamic> body = json.decode(resp.body);

      // 2) matchResultList 필드만 List<dynamic>으로 꺼내고
      final listJson = body['matchResultList'] as List<dynamic>?;

      if (listJson == null) {
        throw Exception('matchResultList가 없습니다.');
      }

      // 3) Map->MatchResult로 변환하여 반환
      return listJson
          .map((e) => MatchResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final err = json.decode(resp.body);
      throw Exception('전체 경기 로드 실패: ${err['responseMessage'] ?? resp.body}');
    }
  }


  /// 4) 매치 상세 정보 조회
  Future<MatchDetail> fetchMatchDetail({
    required int userId,
    required int teamId,
    required int matchId,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/MatchInfo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'userId': userId,
        'teamId': teamId,
        'matchId': matchId,
      }),
    );

    if (resp.statusCode == 200) {
      final body = json.decode(resp.body) as Map<String,dynamic>;
      return MatchDetail.fromJson(body);
    } else {
      final err = json.decode(resp.body);
      throw Exception('매치 상세 로드 실패: ${err['responseMessage'] ?? resp.body}');
    }
  }

  Future<MatchStats> fetchMatchStats({
    required int teamId,
    required int matchId,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/MatchInfo/MatchDetail'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'teamId': teamId,
        'matchId': matchId,
      }),
    );

    final body = json.decode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200) {
      return MatchStats.fromJson(body);
    }
    else {
      throw Exception('매치 통계 로드 실패: ${body['responseMessage'] ?? resp.body}');
    }
  }

}

final teamInfoProvider = FutureProvider
    .family<TeamInfo, Tuple3<String, int, int>>((ref, params) {
  final token = params.item1;
  final userId = params.item2;
  final teamId = params.item3;

  if (token.isEmpty) {
    throw Exception('로그인 정보가 없습니다.');
  }

  return TeamInfoService(token: token)
      .fetchTeamInfo(userId: userId, teamId: teamId);
});

/// Riverpod 프로바이더 등록
final allMatchResultsProvider = FutureProvider
    .family<List<MatchResult>, Tuple2<String,int>>((ref, params) {
  final token = params.item1;
  final teamId = params.item2;
  if (token.isEmpty) throw Exception('로그인 정보가 없습니다.');
  return TeamInfoService(token: token)
      .fetchAllMatches(teamId: teamId);
});

/// Riverpod 프로바이더 등록
final matchDetailProvider = FutureProvider
    .family<MatchDetail, Tuple4<String,int,int,int>>((ref, params) {
  final token   = params.item1;
  final userId  = params.item2;
  final teamId  = params.item3;
  final matchId = params.item4;
  return TeamInfoService(token: token)
      .fetchMatchDetail(userId: userId, teamId: teamId, matchId: matchId);
});


// ─── Riverpod provider 등록 ─────────────────────────────────────────────
final matchStatsProvider = FutureProvider
    .family<MatchStats, Tuple3<String,int,int>>((ref, params) {
  final token   = params.item1;
  final teamId  = params.item2;
  final matchId = params.item3;
  return TeamInfoService(token: token)
      .fetchMatchStats(teamId: teamId, matchId: matchId);
});