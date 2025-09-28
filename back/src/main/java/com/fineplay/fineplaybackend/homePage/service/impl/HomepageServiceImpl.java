package com.fineplay.fineplaybackend.homePage.service.impl;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.homePage.dto.request.*;
import com.fineplay.fineplaybackend.homePage.dto.response.*;
import com.fineplay.fineplaybackend.notification.repository.NotificationReceiverRepository;
import com.fineplay.fineplaybackend.team.repository.*;
import com.fineplay.fineplaybackend.user.repository.*;
import com.fineplay.fineplaybackend.auth.repository.*;
import com.fineplay.fineplaybackend.homePage.service.HomepageService;
import com.fineplay.fineplaybackend.team.entity.*;
import com.fineplay.fineplaybackend.user.entity.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HomepageServiceImpl implements HomepageService {
    private final UserRepository userRepository;
    private final UserStatRepository userStatRepository;
    private final UserStatImgRepository userStatImgRepository;
    private final UserTeamRepository userTeamRepository;
    private final TeamRepository teamRepository;
    private final TeamStatRepository teamStatRepository;
    private final NotificationReceiverRepository receiverRepo;


    // ✅ 1. 홈페이지 조회
    @Override
    public HomepageResponseDto getHomePage(Long userId) {

        // 1) 유저 존재 검증
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID"));

        // 2) 유저 스탯 조회
        UserStatEntity stat = userStatRepository.findByUserId(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID_FOR_USER_STAT"));

        // 3) 현재 팀(Optional) 조회
        Optional<UserTeamEntity> currentUserTeamOpt =
                userTeamRepository.findByUserIdAndIsCurrentTrue(userId);

        // 초기값 null 설정
        String currentTeamName = null;
        String teamImg        = null;
        String fw             = null;
        String mf             = null;
        String df             = null;

        if (currentUserTeamOpt.isPresent()) {
            // 4) 팀 엔티티에서 필요한 정보 꺼내기
            TeamEntity team = currentUserTeamOpt.get().getTeam();
            currentTeamName = team.getTeamName();
            teamImg         = team.getTeamImg();

            // 5) 팀 스탯 조회
            TeamStatEntity teamStat = teamStatRepository.findByTeamId(team.getTeamId())
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.BAD_REQUEST, "TEAM_STAT_NOT_FOUND"));
            fw = String.valueOf(teamStat.getFW());
            mf = String.valueOf(teamStat.getMF());
            df = String.valueOf(teamStat.getDF());
        }

        boolean hasUnread = receiverRepo.existsByUserIdAndIsReadFalse(userId);

        return HomepageResponseDto.builder()
                .status(200)
                .userName(user.getNickName())
                .position(user.getPosition())
                .profileImg(user.getProfileImg())
                .ovr(String.valueOf(stat.getOVR()))
                .selectedStat(stat.getSelectedStat())

                // Special Stats
                .CRO(stat.getCRO())
                .HED(stat.getHED())
                .FST(stat.getFST())
                .ACT(stat.getACT())
                .OFF(stat.getOFF())
                .TEC(stat.getTEC())
                .COP(stat.getCOP())

                // Common Stats
                .PAC(stat.getPAC())
                .PAS(stat.getPAS())
                .SPD(stat.getSPD())

                // Position Stats: FW
                .SHO(stat.getSHO())
                .DRV(stat.getDRV())

                // Position Stats: MF
                .DEC(stat.getDEC())
                .DRI(stat.getDRI())

                // Position Stats: DF
                .TAC(stat.getTAC())
                .BLD(stat.getBLD())

                // 현재 팀 정보 (존재하지 않으면 null)
                .currentTeam(currentTeamName)
                .teamImg(teamImg)
                .fw(fw)
                .mf(mf)
                .df(df)
                .hasUnreadNotification(hasUnread)
                .build();
    }

    // ✅ 2. 팀 변경위한 토글 버튼 클릭

    @Override
    public TeamListResponseDto getTeamList(Long userId) {
        // 1) user 검증
        userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "INVALID_USER_ID"));

        // 2) 가입/참여 중인 팀 조회
        List<UserTeamEntity> userTeams = userTeamRepository.findAllByUserId(userId);

        // 3) DTO 변환
        List<TeamListResponseDto.TeamDto> teams = userTeams.stream()
                .limit(3)
                .map(ut -> {
                    TeamEntity t = ut.getTeam();
                    return new TeamListResponseDto.TeamDto(
                            t.getTeamId(),
                            t.getTeamName()
                    );
                })
                .collect(Collectors.toList());

        // 4) 3개 미만이면 null 엔트리로 패딩
        while (teams.size() < 3) {
            teams.add(new TeamListResponseDto.TeamDto(null, null));
        }

        // 4) 응답 빌드
        return TeamListResponseDto.builder()
                .status(200)
                .MyTeamList(teams)
                .build();
    }


    // ✅ 3. 변경할 팀 선택
    @Override
    @Transactional
    public ChangeTeamResponseDto changeTeam(Long tokenUserId, Long userId, Long teamId) {

        //토큰 아이디와 userid매칭 되는지 검증 다른사람거 변경안되도록 방지
        if (!tokenUserId.equals(userId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID_MISMATCH");
        }

        // 1) 유저 존재 검증
        userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "INVALID_USER_ID"));

        // 2) 해당 조합 존재 검증
        UserTeamEntity target = userTeamRepository
                .findByUserIdAndTeamId(userId, teamId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "TEAM_NOT_FOUND"));

        // 3) userId에 해당하는 기존에 isCurrent==true 인 모든 팀을 false 로
        List<UserTeamEntity> all = userTeamRepository.findAllByUserId(userId);
        for (UserTeamEntity ut : all) {
            if (ut.isCurrent()) {
                ut.setCurrent(false);
                userTeamRepository.save(ut);
            }
        }

        // 4) 선택된 팀을 true 로
        target.setCurrent(true);
        userTeamRepository.save(target);

        // 5) 팀 정보 및 스탯 조회
        TeamEntity team = target.getTeam();
        TeamStatEntity stat = teamStatRepository
                .findByTeamId(team.getTeamId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "TEAM_STAT_NOT_FOUND"));

        // 6) Response DTO 빌드
        return ChangeTeamResponseDto.builder()
                .status(200)
                .currentTeam(team.getTeamName())
                .teamImg(team.getTeamImg())
                .win(String.valueOf(team.getTotalWin()))
                .draw(String.valueOf(team.getTotalDraw()))
                .lose(String.valueOf(team.getTotalLose()))
                .fw(String.valueOf(stat.getFW()))
                .mf(String.valueOf(stat.getMF()))
                .df(String.valueOf(stat.getDF()))
                .build();
    }

    @Override
    public TeamCurrentResponseDto getCurrentTeam(TeamCurrentRequestDto requestDto) {
        UserTeamEntity userTeam = userTeamRepository.findByUserIdAndIsCurrentTrue(requestDto.getUserId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "현재 팀이 존재하지 않습니다."));

        return new TeamCurrentResponseDto(userTeam.getTeamId());
    }
}
