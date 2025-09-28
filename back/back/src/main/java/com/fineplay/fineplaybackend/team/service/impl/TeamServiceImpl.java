package com.fineplay.fineplaybackend.team.service.impl;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
import com.fineplay.fineplaybackend.notification.repository.NotificationReceiverRepository;
import com.fineplay.fineplaybackend.team.dto.request.CreateTeamRequestDto;
import com.fineplay.fineplaybackend.team.dto.request.TeamUpdateRequestDto;
import com.fineplay.fineplaybackend.team.dto.response.*;
import com.fineplay.fineplaybackend.team.entity.TeamEntity;
import com.fineplay.fineplaybackend.team.entity.TeamRequestListEntity;
import com.fineplay.fineplaybackend.team.entity.TeamStatEntity;
import com.fineplay.fineplaybackend.team.repository.TeamRequestListRepository;
import com.fineplay.fineplaybackend.team.repository.TeamRepository;
import com.fineplay.fineplaybackend.team.service.TeamService;
import com.fineplay.fineplaybackend.user.entity.UserStatEntity;
import com.fineplay.fineplaybackend.user.entity.UserTeamEntity;
import com.fineplay.fineplaybackend.user.repository.UserTeamRepository;
import com.fineplay.fineplaybackend.user.repository.UserStatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.fineplay.fineplaybackend.notification.service.NotificationService;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TeamServiceImpl implements TeamService {

    private final TeamRepository teamRepository;
    private final UserRepository userRepository;
    private final TeamRequestListRepository TeamRequestListRepository;
    private final UserTeamRepository userTeamRepository;
    private final UserStatRepository userStatRepository;
    private final NotificationService notificationService;
    private final NotificationReceiverRepository receiverRepo;

    /**
     * 팀 이름 사용 가능 여부 확인
     */
    @Override
    public boolean isTeamNameAvailable(String teamName) {
        return !teamRepository.existsByTeamName(teamName);
    }

    /**
     * 팀 생성: 팀 리더를 설정하고, 리더의 팀 가입 정보를 UserTeamEntity로 저장
     */
    @Override
    @Transactional
    public TeamCreationResponseDto createTeam(CreateTeamRequestDto requestDto, Long userId) {
        if (userId == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "USER_ID_NULL");        }
        // 팀 이름 중복 확인
        if (teamRepository.existsByTeamName(requestDto.getTeamName())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "DUPLICATE_TEAM_NAME");        }
        // 팀 리더(UserEntity) 조회
        UserEntity leader = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND"));
        // 팀 생성 및 저장
        TeamEntity team = new TeamEntity();
        team.setTeamName(requestDto.getTeamName());
        // region, teamType, teamImg 등 필요 필드를 추가로 설정 가능
        team.setTeamLeader(leader);
        team.setRegion(requestDto.getHomeTown1()+" "+requestDto.getHomeTown2());
        team.setTeamType(requestDto.getSports());
        team = teamRepository.save(team);
        Long createdTeamId = team.getTeamId();

        // 이중 검증: 사용자의 현재 가입 건수 확인 (최대 3개)
        int currentTeamCount = userTeamRepository.countByUserId(userId);
        if (currentTeamCount >= 3) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "USER_ALREADY_IN_MAX_TEAMS");
        }
        // 리더의 팀 가입 정보 추가 (isCurrent는 true로 설정)
        UserTeamEntity leaderTeam = UserTeamEntity.builder()
                .userId(userId)
                .teamId(createdTeamId)
                .user(leader)
                .team(team)
                .isCurrent(userTeamRepository.findAllByUserId(userId).isEmpty())
                .build();

        userTeamRepository.save(leaderTeam);
        int teamMemberNum=userTeamRepository.countByTeamId(createdTeamId);
        team.setMemberNum(teamMemberNum);
        return new TeamCreationResponseDto(null); // 성공
    }

    /**
     * 내 팀 조회: 해당 사용자가 가입한 팀들을 UserTeamEntity를 통해 조회
     */
    @Override
    @Transactional(readOnly = true)
    public TeamListResponseDto getMyTeams(Long userId) {
        List<UserTeamEntity> memberships = userTeamRepository.findAllByUserId(userId);
        if (memberships.isEmpty()) {
            boolean hasUnread = receiverRepo.existsByUserIdAndIsReadFalse(userId);
            return new TeamListResponseDto(404, "가입된 팀이 없습니다.", List.of(), hasUnread);
        }
        List<TeamResponseDto> teamList = memberships.stream().map(ut -> {
            TeamEntity team = ut.getTeam();
            TeamStatEntity teamStat = team.getTeamStat();
            boolean leader = team.getTeamLeader() != null
                    && team.getTeamLeader().getUserId().equals(userId);
            return new TeamResponseDto(
                    team.getTeamId(),
                    team.getTeamName(),
                    team.getTeamImg(),
                    String.valueOf(teamStat.getTeamOVR()), // OVR (임시 데이터)
                    String.valueOf(team.getTotalWin()),   // Win (임시 데이터)
                    String.valueOf(team.getTotalDraw()), // Draw (임시 데이터)
                    String.valueOf(team.getTotalLose()),// Lose (임시 데이터)
                    team.getRegion(),
                    String.valueOf(team.getMemberNum()),
                    team.getTeamType(),
                    leader
            );
        }).collect(Collectors.toList());

        boolean hasUnread = receiverRepo.existsByUserIdAndIsReadFalse(userId);
        return new TeamListResponseDto(200, "팀 리스트", teamList, hasUnread);
    }

    /**
     * 팀 가입 요청
     */
    @Override
    @Transactional
    public String requestJoinTeam(Long userId, Long teamId) {
        // 팀과 사용자 존재 여부 확인
        if (!teamRepository.existsById(teamId)) {throw new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND");}
        if (!userRepository.existsById(userId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND");
        }

        // 이미 가입한 팀이 3개 이상인 경우 가입 요청을 거부
        int currentTeamCount = userTeamRepository.countByUserId(userId);
        if (currentTeamCount >= 3) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "USER_ALREADY_IN_MAX_TEAMS");
        }

        // 가입 요청 중복 체크
        if (TeamRequestListRepository.existsByTeam_TeamIdAndUser_UserId(teamId, userId)){
            throw new ResponseStatusException(HttpStatus.CONFLICT, "ALREADY_REQUESTED");
        }
        // 이미 가입한 팀 여부 확인
        if (userTeamRepository.existsByUserIdAndTeamId(userId, teamId))  throw new ResponseStatusException(HttpStatus.CONFLICT, "ALREADY_IN_TEAM");
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND"));
        TeamEntity team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));
        // 가입 요청 저장
        TeamRequestListEntity joinRequest = new TeamRequestListEntity(null, user, team);
        TeamRequestListRepository.save(joinRequest);


        // 알림: 팀장에게 요청 사실 알리기
        notificationService.notifyTeamLeaderOnRequest(teamId, userId);

        return "JOIN_REQUEST_SUBMITTED";
    }

    /**
     * 팀 가입 요청 목록 조회 (팀 리더 전용)
     */
    @Override
    @Transactional(readOnly = true)
    public List<TeamRegisterManageResponseDto> getTeamJoinRequests(Long teamId, Long leaderId) {
        TeamEntity team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));
        if (team.getTeamLeader() == null || !team.getTeamLeader().getUserId().equals(leaderId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "NOT_TEAM_LEADER");
        }
        List<TeamRequestListEntity> joinRequests = TeamRequestListRepository.findByTeam_TeamId(teamId);
        return joinRequests.stream().map(request -> {
            Long reqUserId = request.getUser().getUserId();
            UserEntity user = userRepository.findById(reqUserId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND"));
            UserStatEntity stat = null;
            try {
                stat = /* userStatRepository.findByUserId(reqUserId).orElse(null) */ null; // 필요 시 통계 조회 로직 추가
            } catch (Exception e) {
                // 통계 정보가 없으면 null 처리
            }
            return new TeamRegisterManageResponseDto(
                    user.getNickName(),
                    user.getPosition(),
                    stat != null ? String.valueOf(stat.getOVR()) : "N/A",
                    user.getUserId()
            );
        }).collect(Collectors.toList());
    }

    /**
     * 팀 가입 승인: 가입 요청을 확인 후 UserTeamEntity에 가입 정보를 추가
     */
    @Override
    @Transactional
    public String acceptJoinRequest(Long teamId, Long userId, Long leaderId) {
        TeamEntity team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));
        if (team.getTeamLeader() == null || !team.getTeamLeader().getUserId().equals(leaderId))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "NOT_TEAM_LEADER");
        if (!TeamRequestListRepository.existsByTeam_TeamIdAndUser_UserId(teamId, userId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "NO_JOIN_REQUEST");
        }
        // 이중 검증: 사용자의 현재 가입 건수 확인 (최대 3개)
        int currentTeamCount = userTeamRepository.countByUserId(userId);
        if (currentTeamCount >= 3) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "USER_ALREADY_IN_MAX_TEAMS");
        }
        // 가입 정보 추가
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND"));
        UserTeamEntity membership = UserTeamEntity.builder()
                .userId(userId)
                .teamId(teamId)
                .user(user)
                .team(team)
                .isCurrent(false)  // 가입 시 기본값은 false; 필요에 따라 조정
                .build();
        userTeamRepository.save(membership);
        int teamMemberNum=userTeamRepository.countByTeamId(teamId);
        team.setMemberNum(teamMemberNum);
        // 가입 요청 기록 삭제
        TeamRequestListRepository.deleteByTeam_TeamIdAndUser_UserId(teamId, userId);


        // 알림: 신청자에게 승인 알림
        notificationService.notifyApplicantOnResult(teamId, userId, true);

        return "JOIN_ACCEPTED";
    }

    /**
     * 팀 가입 거절
     */
    @Override
    @Transactional
    public String rejectJoinRequest(Long teamId, Long userId, Long leaderId) {
        TeamEntity team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));
        if (team.getTeamLeader() == null || !team.getTeamLeader().getUserId().equals(leaderId))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "NOT_TEAM_LEADER");
        if (!TeamRequestListRepository.existsByTeam_TeamIdAndUser_UserId(teamId, userId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "NO_JOIN_REQUEST");

        }
        TeamRequestListRepository.deleteByTeam_TeamIdAndUser_UserId(teamId, userId);

        // 알림: 신청자에게 거절 알림
        notificationService.notifyApplicantOnResult(teamId, userId, false);


        return "JOIN_REJECTED";
    }

    /**
     * 팀원 목록 조회: 특정 팀에 가입한 회원들을 UserTeamEntity를 통해 조회
     */
    @Override
    @Transactional(readOnly = true)
    public List<TeamMemberListResponseDto> getTeamMembers(Long teamId) {
        TeamEntity team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));
        Long leaderId = team.getTeamLeader() != null ? team.getTeamLeader().getUserId() : null;
        List<UserTeamEntity> memberships = userTeamRepository.findAllByTeamId(teamId);
        return memberships.stream().map(ut -> {
            Long uid = ut.getUserId();
            boolean isLeader = uid.equals(leaderId);
            UserEntity user = userRepository.findById(uid)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND"));
            UserStatEntity stat = null;
            try {
                stat =  userStatRepository.findByUserId(uid).orElse(null); // 통계 조회 로직 추가 가능
            } catch (Exception e) { }
            return new TeamMemberListResponseDto(
                    uid,
                    isLeader,
                    user.getNickName(),
                    stat != null ? String.valueOf(stat.getOVR()) : "N/A"
            );
        }).collect(Collectors.toList());
    }

    /**
     * 팀 정보 업데이트: 팀 리더만 업데이트 가능
     */
    @Override
    @Transactional
    public String updateTeamInfo(TeamUpdateRequestDto updateDto, Long leaderId) {
        TeamEntity team = teamRepository.findById(Long.valueOf(updateDto.getTeamID()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));
        if (team.getTeamLeader() == null || !team.getTeamLeader().getUserId().equals(leaderId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "NOT_TEAM_LEADER");
        }
        if (!team.getTeamName().equals(updateDto.getTeamName()) &&
                teamRepository.existsByTeamName(updateDto.getTeamName())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "DUPLICATE_TEAM_NAME");
        }
        team.setTeamName(updateDto.getTeamName());
        team.setRegion(updateDto.getHomeTown1()+" "+updateDto.getHomeTown2());
        teamRepository.save(team);
        return "TEAM_UPDATE_SUCCESS";
    }

    /**
     * 팀 탈퇴 처리: 탈퇴 시 UserTeamEntity에서 제거하고, 만약 탈퇴자가 팀 리더라면 새 리더 위임
     */
    @Override
    @Transactional
    public String leaveTeam(Long teamId, Long userId) {
        TeamEntity team = teamRepository.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));

        if (!userTeamRepository.existsByUserIdAndTeamId(userId, teamId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "USER_NOT_IN_TEAM");
        }
        // 팀 리더인 경우, 다른 구성원이 있다면 새 리더 위임
        if (userId.equals(team.getTeamLeader().getUserId())) {
            List<UserTeamEntity> memberships =   userTeamRepository.findAllByTeamIdOrderByJoinedAtAsc(teamId);
            Optional<UserTeamEntity> newLeaderOpt = memberships.stream()
                    .filter(ut -> !ut.getUserId().equals(userId))
                    .findFirst();
            if (newLeaderOpt.isPresent()) {
                UserEntity newLeader = userRepository.findById(newLeaderOpt.get().getUserId())
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "NEW_LEADER_NOT_FOUND"));
                team.setTeamLeader(newLeader);
            } else {
                userTeamRepository.deleteByUserIdAndTeamId(userId, teamId);
                teamRepository.deleteByTeamId(teamId);
                int teamMemberNum=userTeamRepository.countByTeamId(teamId);
                team.setMemberNum(teamMemberNum);
                return "TEAM_LEAVE_DELETE_SUCCESS";
            }
        }
        // 팀 탈퇴 처리: 해당 UserTeamEntity 삭제
        userTeamRepository.deleteByUserIdAndTeamId(userId, teamId);
        int teamMemberNum=userTeamRepository.countByTeamId(teamId);
        team.setMemberNum(teamMemberNum);
        return "TEAM_LEAVE_SUCCESS";
    }

    /**
     * 팀 검색
     */
    @Override
    public List<TeamSearchResponseDto> searchTeams(String searchContent) {
        List<TeamEntity> teams = teamRepository.findByTeamNameContaining(searchContent);
        return teams.stream()
                .map(team -> new TeamSearchResponseDto(team.getTeamName(), team.getTeamId()))
                .collect(Collectors.toList());
    }
}
