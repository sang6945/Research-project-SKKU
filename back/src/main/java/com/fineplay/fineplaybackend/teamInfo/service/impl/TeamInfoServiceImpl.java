package com.fineplay.fineplaybackend.teamInfo.service.impl;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.homePage.dto.response.HomepageResponseDto;
import com.fineplay.fineplaybackend.homePage.dto.response.TeamListResponseDto;
import com.fineplay.fineplaybackend.match.dto.response.RecentMatchRecordResponseDto;
import com.fineplay.fineplaybackend.teamInfo.dto.request.*;
import com.fineplay.fineplaybackend.teamInfo.dto.response.*;
import com.fineplay.fineplaybackend.team.repository.*;
import com.fineplay.fineplaybackend.user.repository.*;
import com.fineplay.fineplaybackend.auth.repository.*;
import com.fineplay.fineplaybackend.match.repository.*;
import com.fineplay.fineplaybackend.match.service.MatchService;
import com.fineplay.fineplaybackend.match.entity.MatchesEntity;
import com.fineplay.fineplaybackend.teamInfo.service.TeamInfoService;
import com.fineplay.fineplaybackend.team.entity.*;
import com.fineplay.fineplaybackend.user.entity.*;
import com.fineplay.fineplaybackend.match.entity.*;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.text.SimpleDateFormat;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeamInfoServiceImpl implements TeamInfoService {
    private final UserRepository userRepository;
    private final UserStatRepository userStatRepository;
    private final UserStatImgRepository userStatImgRepository;
    private final UserTeamRepository userTeamRepository;
    private final TeamRepository teamRepository;
    private final TeamStatRepository teamStatRepository;
    private final TeamRequestListRepository teamRequestListRepository;
    private final MatchesRepository matchesRepository;
    private final MatchReportRepository matchReportRepository;
    private final ScorerRepository scorerRepository;
    private final UserMatchStatRepository userMatchStatRepository;
    private final MatchService matchService;



    private static final SimpleDateFormat SDF = new SimpleDateFormat("yyyy.MM.dd");


    // ✅ 1. 팀정보 조회
    @Override
    public TeamInfoResponseDto getTeamInfo(Long tokenUserId, Long userId, Long teamId) {

        //토큰 아이디와 userid매칭 되는지 검증
        if (!tokenUserId.equals(userId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID_MISMATCH");
        }

        // 1) 유저 존재 검증
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID"));

        // 2) 조회할 팀 로드
        TeamEntity team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_TEAM_ID"));

        // 3) 팀 통계 로드 (없으면 기본값)
        TeamStatEntity stat = teamStatRepository.findById(teamId).orElse(new TeamStatEntity());

        // 4) 가입 상태 결정
        String registerStatus;
        if (userTeamRepository.existsByUserIdAndTeamId(userId, teamId)) {
            registerStatus = "Registered";
        } else if (teamRequestListRepository.existsByUser_UserIdAndTeam_TeamId(userId, teamId)) {
            registerStatus = "Waiting";
        } else {
            registerStatus = "Not Registered";
        }

        // 5) 최근 15경기 통계

        RecentMatchRecordResponseDto record = matchService.getRecentMatchRecord(teamId);

        String win15 = String.valueOf(record.getRecentWin());
        String draw15 = String.valueOf(record.getRecentDraw());
        String lose15 = String.valueOf(record.getRecentLose());


        // 6) 전체 전적 & 승률
        int totalWin  = team.getTotalWin();
        int totalDraw = team.getTotalDraw();
        int totalLose = team.getTotalLose();
        int totalMat  = totalWin + totalDraw + totalLose;
        int winRate   = totalMat > 0 ? (int)((double) totalWin * 100 / totalMat) : 0;

        // 7) 최신 5경기 리스트
        List<TeamInfoResponseDto.MatchResultDto> recent5 = matchesRepository
                .findTop5ByHomeTeamIdOrAwayTeamIdOrderByMatchDateDesc(teamId, teamId)
                .stream()
                .map(m -> {
                    TeamInfoResponseDto.MatchResultDto dto = new TeamInfoResponseDto.MatchResultDto();

                    // 1) 날짜 포맷팅 (Date → String)
                    Date rawDate = m.getMatchDate();  // java.util.Date or Timestamp
                    dto.setDate(SDF.format(rawDate));

                    // 2) 결과 판정
                    Long result = m.getResult();
                    if (result != null && result.equals(teamId)) {
                        dto.setResult("Win");
                    } else if (result != null && result.equals(-1L)) {
                        dto.setResult("Draw");
                    } else {
                        dto.setResult("Lose");
                    }

                    // 3) 홈/어웨이 팀 이름
                    Long homeId = m.getHomeTeamId();
                    String homeName;
                    if (homeId == null || homeId == 0L) {
                        homeName = "홈팀";
                    } else {
                        homeName = teamRepository.findById(homeId)
                                .map(TeamEntity::getTeamName)
                                .orElse("홈팀");
                    }
                    dto.setHometeam(homeName);

                    Long awayId = m.getAwayTeamId();
                    String awayName;
                    if (awayId == null || awayId == 0L) {
                        awayName = "어웨이팀";
                    } else {
                        awayName = teamRepository.findById(awayId)
                                .map(TeamEntity::getTeamName)
                                .orElse("어웨이팀");
                    }
                    dto.setAwayteam(awayName);

                    // 4) 스코어 및 매치 ID
                    dto.setHomeScore(String.valueOf(m.getHomeScore()));
                    dto.setAwayScore(String.valueOf(m.getAwayScore()));
                    dto.setMatchId(String.valueOf(m.getMatchId()));
                    return dto;
                })
                .collect(Collectors.toList());


        int teamOvr = stat.getTeamOVR();

        // — 전체 팀 수 & 더 높은 OVR을 가진 팀 수
        long totalTeams   = teamStatRepository.count();
        long higherTeams  = teamStatRepository.countByTeamOVRGreaterThan(teamOvr);

        // — 상위 퍼센트 계산 (더 높은 수 / 전체 ×100, 올림)
        int ovrPercent = totalTeams > 0
                ? (int) Math.ceil(higherTeams * 100.0 / totalTeams)
                : 0;


        //막대그래프 정보
        int[][] bins = {
                {0,9}, {10,19}, {20,29}, {30,39}, {40,49},
                {50,59}, {60,69}, {70,79}, {80,89}, {90,100}
        };
        String[] labels = {
                "0","10","20","30","40","50",
                "60","70","80","90"
        };

        // 8-2) DTO 리스트 초기화
        List<TeamInfoResponseDto.StatDistributionDto> statDistribution = new ArrayList<>();
        for (int i = 0; i < bins.length; i++) {
            statDistribution.add(
                    TeamInfoResponseDto.StatDistributionDto.builder()
                            .range(labels[i])
                            .fwCount(0)
                            .mfCount(0)
                            .dfCount(0)
                            .build()
            );
        }

        List<UserTeamEntity> userTeams = userTeamRepository.findAllByTeamId(teamId);
        // 2) 회원 ID 리스트 추출
        List<Long> memberIds = userTeams.stream()
                .map(UserTeamEntity::getUserId)
                .collect(Collectors.toList());

        // 3) 회원정보와 stat을 한 번에 batch 조회
        List<UserEntity> users = userRepository.findAllById(memberIds);
        Map<Long, String> positionMap = users.stream()
                .collect(Collectors.toMap(UserEntity::getUserId, UserEntity::getPosition));

        List<UserStatEntity> stats = userStatRepository.findAllById(memberIds);
        Map<Long, Integer> ovrMap = stats.stream()
                .collect(Collectors.toMap(UserStatEntity::getUserId, UserStatEntity::getOVR));

        for (Long uid : memberIds) {
            String pos = positionMap.getOrDefault(uid, "");
            int ovrValue = ovrMap.getOrDefault(uid, 0);

            for (int i = 0; i < bins.length; i++) {
                if (ovrValue >= bins[i][0] && ovrValue <= bins[i][1]) {
                    TeamInfoResponseDto.StatDistributionDto dto = statDistribution.get(i);
                    switch (pos.toUpperCase()) {
                        case "FW":
                            dto.setFwCount(dto.getFwCount() + 1);
                            break;
                        case "MF":
                            dto.setMfCount(dto.getMfCount() + 1);
                            break;
                        case "DF":
                            dto.setDfCount(dto.getDfCount() + 1);
                            break;
                        default:
                            break;
                    }
                    break;
                }
            }
        }


        return TeamInfoResponseDto.builder()
                .status(200)
                .responseMessage("팀 정보 화면")
                .teamName(team.getTeamName())
                .teamImg(team.getTeamImg())
                .OVR(String.valueOf(stat.getTeamOVR()))
                .ovrPercent(String.valueOf(ovrPercent))
                .recentWin15(win15)
                .recentDraw15(draw15)
                .recentLose15(lose15)
                .homeTown(team.getRegion())
                .memberNum(String.valueOf(team.getMemberNum()))
                .sports(team.getTeamType())
                .teamRegister(registerStatus)
                .OVR_dist(team.getOVRDist())
                .FW(String.valueOf(stat.getFW()))
                .DF(String.valueOf(stat.getDF()))
                .MF(String.valueOf(stat.getMF()))
                .SPD(String.valueOf(stat.getSPD()))
                .PAS(String.valueOf(stat.getPAS()))
                .PAC(String.valueOf(stat.getPAC()))
                .totalWin(String.valueOf(totalWin))
                .totalDraw(String.valueOf(totalDraw))
                .totalLose(String.valueOf(totalLose))
                .winningRate(String.valueOf(winRate))
                .matchResultList(recent5)
                .statDistribution(statDistribution)
                .build();
    }

    // ✅ 2. 모든 매치 조회 - 더보기 버튼
    @Override
    public AllMatchResponseDto getAllMatches(Long teamId) {
        // 1) 팀 존재 여부 확인
        teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_TEAM_ID"));

        // 2) 팀 관련 모든 경기 조회 (홈팀 또는 어웨이팀)
        List<MatchesEntity> matches = matchesRepository
                .findByHomeTeamIdOrAwayTeamIdOrderByMatchDateDesc(teamId, teamId);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd");

        // 3) 매치 결과 리스트 생성
        List<AllMatchResponseDto.MatchResultDto> matchResults = matches.stream()
                .map(m -> {
                    AllMatchResponseDto.MatchResultDto dto = new AllMatchResponseDto.MatchResultDto();

                    dto.setDate(sdf.format(m.getMatchDate()));

                    Long result = m.getResult();
                    if (result != null && result.equals(teamId)) {
                        dto.setResult("Win");
                    } else if (result != null && result.equals(-1L)) {
                        dto.setResult("Draw");
                    } else {
                        dto.setResult("Lose");
                    }
                    // 3) 홈/어웨이 팀 이름
                    Long homeId = m.getHomeTeamId();
                    String homeName;
                    if (homeId == null || homeId == 0L) {
                        homeName = "홈팀";
                    } else {
                        homeName = teamRepository.findById(homeId)
                                .map(TeamEntity::getTeamName)
                                .orElse("홈팀");
                    }
                    dto.setHometeam(homeName);

                    Long awayId = m.getAwayTeamId();
                    String awayName;
                    if (awayId == null || awayId == 0L) {
                        awayName = "어웨이팀";
                    } else {
                        awayName = teamRepository.findById(awayId)
                                .map(TeamEntity::getTeamName)
                                .orElse("어웨이팀");
                    }
                    dto.setAwayteam(awayName);

                    dto.setHomeScore(String.valueOf(m.getHomeScore()));
                    dto.setAwayScore(String.valueOf(m.getAwayScore()));
                    dto.setMatchId(String.valueOf(m.getMatchId()));
                    return dto;
                })
                .collect(Collectors.toList());

        // 4) AllMatchResponseDto 빌드 및 반환
        return AllMatchResponseDto.builder()
                .status(200)
                .responseMessage("전체 매치 리스트")
                .matchResultList(matchResults)
                .build();
    }

    // ✅ 3. 매치정보 조회
    @Override
    public MatchInfoResponseDto getMatchInfo(Long userId, Long teamId, Long matchId) {
        // 1) 사용자 검증
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID"));

        // 2) match 조회
        MatchesEntity match = matchesRepository.findById(matchId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_MATCH_ID"));

        // 3) home/away 팀 이름 (존재하지 않으면 기본값)
        Long homeId = match.getHomeTeamId();
        Long awayId = match.getAwayTeamId();


        // → 받은 teamId가 이 경기의 home/away 둘 다 아니라면 에러
        if (!Objects.equals(teamId, homeId) && !Objects.equals(teamId, awayId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "TEAM_NOT_IN_MATCH");
        }

        // 3-1) 팀 소속 여부 체크 (user_team)
        boolean isMember = userTeamRepository.existsByUserIdAndTeamId(userId, teamId);

        // 4) home/away 팀 이름 (존재하지 않으면 기본값)
        String homeName = homeId != null
                ? teamRepository.findById(homeId).map(TeamEntity::getTeamName).orElse("홈팀")
                : "홈팀";
        String awayName = awayId != null
                ? teamRepository.findById(awayId).map(TeamEntity::getTeamName).orElse("어웨이팀")
                : "어웨이팀";

        // 5) formation 결정
        String formation = "";
        if (homeId != null && homeId.equals(teamId)) {
            formation = match.getHomeFormation();
        } else if (awayId != null && awayId.equals(teamId)) {
            formation = match.getAwayFormation();
        }

        // 5) scorer 조회
        List<MatchInfoResponseDto.Scorer> homeScorers = scorerRepository
                .findByMatches_MatchIdAndIsHome(matchId, true)
                .stream()
                .map(e -> new MatchInfoResponseDto.Scorer(e.getTime(), e.getUserName()))
                .collect(Collectors.toList());
        List<MatchInfoResponseDto.Scorer> awayScorers = scorerRepository
                .findByMatches_MatchIdAndIsHome(matchId, false)
                .stream()
                .map(e -> new MatchInfoResponseDto.Scorer(e.getTime(), e.getUserName()))
                .collect(Collectors.toList());

        // 7) user_match_stat 조회 (개별 경기 스탯) — 팀에 속한 경우만
        // 경기만 참여했다면 어디로 조회하든 보이게 하려면 isMember체크 안하기
        Optional<UserMatchStatEntity> umsOpt = Optional.empty();
        umsOpt = userMatchStatRepository.findByUserIdAndMatchId(userId, matchId);

        boolean hasMatchStat = umsOpt.isPresent();
        UserMatchStatEntity ums = umsOpt.orElse(new UserMatchStatEntity());



        // 8) user_stat 조회 (전체 통계, 여기서 selectedStat을 가져옴)
        UserStatEntity ust = userStatRepository.findByUserId(userId)
                .orElse(new UserStatEntity());
        String selStat = ust.getSelectedStat() != null ? ust.getSelectedStat() : "CRO";


        // 8) DTO 빌드
        return MatchInfoResponseDto.builder()
                .statusCode(200)
                .responseMessage("전체 매치 정보")
                .HomeTeam(homeName)
                .AwayTeam(awayName)
                .HomeTeamScore(String.valueOf(match.getHomeScore()))
                .AwayTeamScore(String.valueOf(match.getAwayScore()))
                .Match_Date(SDF.format(match.getMatchDate()))
                .location(match.getLocation())
                .HomeTeam_Scorer(homeScorers)
                .AwayTeam_Scorer(awayScorers)
                .Formation(formation)
                .Position(ums.getMatchPosition())
                .Grade(   hasMatchStat ? String.valueOf(ums.getRating())   : "-")
                .PlayTime(hasMatchStat ? String.valueOf(ums.getRunTime()) : "-")
                .Score(   hasMatchStat ? String.valueOf(ums.getScore())   : "-")
                .Assist(  hasMatchStat ? String.valueOf(ums.getAssist())  : "-")
                .SelectedStat(selStat)
                // 9) 스탯: hasMatchStat 이 true 일 때만 ums 값을, 아니면 -1
                .CRO(hasMatchStat ? ums.getCRO() : -1)
                .HED(hasMatchStat ? ums.getHED() : -1)
                .FST(hasMatchStat ? ums.getFST() : -1)
                .ACT(hasMatchStat ? ums.getACT() : -1)
                .OFF(hasMatchStat ? ums.getOFF() : -1)
                .TEC(hasMatchStat ? ums.getTEC() : -1)
                .COP(hasMatchStat ? ums.getCOP() : -1)

                .PAC(hasMatchStat ? ums.getPAC() : -1)
                .PAS(hasMatchStat ? ums.getPAS() : -1)
                .SPD(hasMatchStat ? ums.getSPD() : -1)

                .SHO(hasMatchStat ? ums.getSHO() : -1)
                .DRV(hasMatchStat ? ums.getDRV() : -1)
                .DEC(hasMatchStat ? ums.getDEC() : -1)
                .DRI(hasMatchStat ? ums.getDRI() : -1)
                .TAC(hasMatchStat ? ums.getTAC() : -1)
                .BLD(hasMatchStat ? ums.getBLD() : -1)
                .build();
    }


    // ✅ 4. 매치 세부 정보 조회
    @Override
    @Transactional
    public MatchDetailResponseDto getMatchDetail(Long teamId, Long matchId) {
        // 1) match 조회
        MatchesEntity match = matchesRepository.findById(matchId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_MATCH_ID"));

        // 2) 팀 매치 일치 검사
        Long homeId = match.getHomeTeamId();
        Long awayId = match.getAwayTeamId();
        if (!Objects.equals(teamId, homeId) && !Objects.equals(teamId, awayId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "TEAM_NOT_IN_MATCH");
        }

        // 3) 홈/어웨이 팀 이름 조회 (없으면 기본)
        String homeTeamName = homeId != null
                ? teamRepository.findById(homeId).map(TeamEntity::getTeamName).orElse("홈팀")
                : "홈팀";
        String awayTeamName = awayId != null
                ? teamRepository.findById(awayId).map(TeamEntity::getTeamName).orElse("어웨이팀")
                : "어웨이팀";


        // 4) match_report 조회
        MatchReportEntity report = matchReportRepository.findById(matchId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_MATCH_ID"));

        // 5) Home/Away 객체 생성
        MatchDetailResponseDto.TeamDetail home = new MatchDetailResponseDto.TeamDetail(
                String.valueOf(report.getHomeGoals()),
                String.valueOf(report.getHomeShots()),
                String.valueOf(report.getHomeShotsOnTarget()),
                String.valueOf(report.getHomePossession()),
                String.valueOf(report.getHomePasses()),
                String.valueOf(report.getHomeTackles()),
                String.valueOf(report.getHomeFouls()),
                String.valueOf(report.getHomeCards()),
                String.valueOf(report.getHomeRatings())
        );

        MatchDetailResponseDto.TeamDetail away = new MatchDetailResponseDto.TeamDetail(
                String.valueOf(report.getAwayGoals()),
                String.valueOf(report.getAwayShots()),
                String.valueOf(report.getAwayShotsOnTarget()),
                String.valueOf(report.getAwayPossession()),
                String.valueOf(report.getAwayPasses()),
                String.valueOf(report.getAwayTackles()),
                String.valueOf(report.getAwayFouls()),
                String.valueOf(report.getAwayCards()),
                String.valueOf(report.getAwayRatings())
        );

        // 6) 최종 DTO 반환
        return MatchDetailResponseDto.builder()
                .statusCode(200)
                .responseMessage("매치 세부 정보")
                .HomeTeamName(homeTeamName)
                .AwayTeamName(awayTeamName)
                .Home(home)
                .Away(away)
                .build();
    }
}
