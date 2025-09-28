package com.fineplay.fineplaybackend.notification.service;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
import com.fineplay.fineplaybackend.match.entity.MatchesEntity;
import com.fineplay.fineplaybackend.match.repository.MatchesRepository;
import com.fineplay.fineplaybackend.match.repository.UserMatchStatRepository;
import com.fineplay.fineplaybackend.notification.dto.NotificationResponseDto;
import com.fineplay.fineplaybackend.notification.entity.Notification;
import com.fineplay.fineplaybackend.notification.entity.NotificationReceiver;
import com.fineplay.fineplaybackend.notification.entity.TargetType;
import com.fineplay.fineplaybackend.notification.repository.NotificationReceiverRepository;
import com.fineplay.fineplaybackend.notification.repository.NotificationRepository;
import com.fineplay.fineplaybackend.team.entity.TeamEntity;
import com.fineplay.fineplaybackend.team.repository.TeamRepository;
import com.fineplay.fineplaybackend.user.repository.UserTeamRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final NotificationRepository          notificationRepo;
    private final NotificationReceiverRepository  receiverRepo;
    private final SseEmitterService               sseService;
    private final UserRepository                  userRepo;
    private final TeamRepository                  teamRepo;
    private final UserTeamRepository              userTeamRepo;
    private final UserMatchStatRepository         userMatchStatRepo;
    private final MatchesRepository               matchRepo;


    /** 1) 공지사항 등록 → 전체 유저 **/
    @Transactional
    public void notifyAllUsers(String title, String content, String link) {
        Notification n = notificationRepo.save(
                Notification.builder()
                        .type("NOTICE")
                        .title(title)
                        .content(content)
                        .targetType(TargetType.ALL)  // 모든 유저에게 보내는 알림
                        .targetId(null)  // 대상 ID는 필요 없으므로 null 처리
                        .build()
        );
        // 모든 유저
        userRepo.findAll().forEach(u -> {
            receiverRepo.save(
                    NotificationReceiver.builder()
                            .notification(n)
                            .userId(u.getUserId())
                            .build()
            );
        });
        sseService.sendToAll(n);
    }

    /** 2) 팀 가입 요청 → 팀장 **/
    @Transactional
    public void notifyTeamLeaderOnRequest(Long teamId, Long applicantId) {
        TeamEntity team = teamRepo.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));
        Long leaderId = team.getTeamLeader().getUserId();

        String teamName = team.getTeamName();  // 팀 이름 가져오기

        // applicantId에 해당하는 UserEntity에서 nickName을 가져옴
        UserEntity applicant = userRepo.findById(applicantId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND"));
        String applicantNickName = applicant.getNickName();


        Notification n = notificationRepo.save(
                Notification.builder()
                        .type("TEAM_REQUEST")
                        .title("새 팀 가입 요청")
                        .content("'"+applicantNickName+"'" + "플레이어가 " + teamName + " 팀 가입 요청을 보냈어요!")  // 팀 이름 포함
                        .targetType(TargetType.USER)  // 팀장에게 보내는 알림
                        .targetId(leaderId)  // 팀장의 userId를 대상 ID로 설정
                        .teamId(teamId)  // teamId 설정
                        .build()
        );
        receiverRepo.save(
                NotificationReceiver.builder()
                        .notification(n)
                        .userId(leaderId)
                        .build()
        );
        sseService.sendNotification(leaderId, n);
    }

    /** 3) 팀 신청 처리 결과 → 신청자 **/
    @Transactional
    public void notifyApplicantOnResult(Long teamId, Long applicantId, boolean approved) {
        String title = approved ? "팀 가입 승인" : "팀 가입 거절";

        TeamEntity team = teamRepo.findById(teamId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TEAM_NOT_FOUND"));
        String teamName = team.getTeamName();  // 팀 이름 가져오기

        // applicantId에 해당하는 UserEntity에서 nickName을 가져옴
        UserEntity applicant = userRepo.findById(applicantId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND"));
        String applicantNickName = applicant.getNickName();

        Notification n = notificationRepo.save(
                Notification.builder()
                        .type("REQUEST_RESULT")
                        .title(title)
                        .content(teamName +" 팀"+ " 가입이 " + (approved ? "승인" : "거절") + "되었어요!")  // 팀 이름과 신청자 nickName 포함
                        .targetType(TargetType.USER)  // 신청자에게 보내는 알림
                        .targetId(applicantId)  // 신청자의 userId를 대상 ID로 설정
                        .teamId(teamId)  // 팀 가입 관련 알림이므로 teamId 설정
                        .build()
        );
        receiverRepo.save(
                NotificationReceiver.builder()
                        .notification(n)
                        .userId(applicantId)
                        .build()
        );
        sseService.sendNotification(applicantId, n);
    }

    /** 4) 내가 뛴 매치 신규 등록 → 참여자 **/
    @Transactional
    public void notifyMatchParticipants(Long matchId, Long userId) {
        // userId가 matchId에 해당하는 참가자인지 확인
        boolean isUserParticipant = userMatchStatRepo.findAll().stream()
                .anyMatch(ums -> ums.getMatchId().equals(matchId) && ums.getUserId().equals(userId));

        // 만약 해당 유저가 이 경기의 참여자라면 알림을 생성하여 보내기
        if (isUserParticipant) {
            // 매치 정보 조회
            MatchesEntity match = matchRepo.findById(matchId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "MATCH_NOT_FOUND"));

            // 매치 날짜 형식화
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String matchDate = sdf.format(match.getMatchDate());

            // 홈/어웨이 팀 이름
            Long homeTeamId = match.getHomeTeamId();
            String homeTeamName = teamRepo.findById(homeTeamId)
                    .map(TeamEntity::getTeamName)
                    .orElse("홈팀");

            Long awayTeamId = match.getAwayTeamId();
            String awayTeamName = teamRepo.findById(awayTeamId)
                    .map(TeamEntity::getTeamName)
                    .orElse("어웨이팀");

            String content = matchDate + " 경기: " + homeTeamName + " vs " + awayTeamName + " 새 경기가 등록되었어요!";

            // 알림 생성
            Notification n = notificationRepo.save(
                    Notification.builder()
                            .type("MATCH_REGISTER")
                            .title("새 경기 등록")
                            .content(content)  // 경기 이름과 날짜 포함
                            .targetType(TargetType.USER)  // 특정 유저에게 보내는 알림
                            .targetId(userId)  // 해당 유저 ID로 설정
                            .matchId(matchId)  // matchId 설정
                            .build()
            );

            // 해당 유저에게 알림 전송
            receiverRepo.save(
                    NotificationReceiver.builder()
                            .notification(n)
                            .userId(userId)  // 해당 유저 ID로 알림을 보내도록 설정
                            .build()
            );

            // 실시간 알림 전송
            sseService.sendNotification(userId, n);
        }
    }

    /** 4) 알림 목록 조회 **/
    @Transactional
    public List<NotificationResponseDto> getNotifications(Long userId) {
        // 1) 사용자 정보 조회
        UserEntity user = userRepo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "USER_NOT_FOUND"));

        // 2) 알림 정보 변환하여 반환
        List<NotificationReceiver> all = receiverRepo.findByUserId(userId);

        // 3) 알림 정보 변환하여 반환
        return all.stream()
                .map(nr -> {
                    Notification notification = nr.getNotification();

                    // 알림을 읽으면 상태를 "read"로 변경
                    String status = nr.getIsRead() ? "read" : "new";


                    nr.setReadAt(LocalDateTime.now());// 읽은 시간 기록
                    nr.setIsRead(true);
                    receiverRepo.save(nr);

                    return NotificationResponseDto.builder()
                            .id(notification.getId())
                            .type(notification.getType())
                            .title(notification.getTitle())
                            .content(notification.getContent())
                            .createdAt(notification.getCreatedAt().toString())  // LocalDateTime을 String으로 변환
                            .userId(nr.getUserId())
                            .teamId(notification.getTeamId())
                            .matchId(notification.getMatchId())
                            .status(status)  // 알림 상태를 "new"로 설정 (필요에 따라 "read" 상태로 업데이트 가능)
                            .build();
                })
                .collect(Collectors.toList());
    }

    /** 5) 알림 삭제 **/
    @Transactional
    public Map<String, String> deleteNotification(Long notificationReceiverId, Long userId) {
        Map<String, String> response = new HashMap<>();
        NotificationReceiver nr = receiverRepo.findById(notificationReceiverId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "NOTIFICATION_NOT_FOUND"));

        // 삭제 요청한 사용자와 알림의 targetId가 일치해야만 삭제 가능
        if (!userId.equals(nr.getUserId())) {
            response.put("message", "삭제 권한이 없습니다.");
            return response;
        }

        Notification notification = nr.getNotification();

        // targetType이 'USER'인 경우 알림을 완전히 삭제
        if (notification.getTargetType().equals(TargetType.USER)) {
            receiverRepo.delete(nr);  // 알림 수신자 삭제
            notificationRepo.delete(notification);  // 해당 알림 삭제
            response.put("message", "알림이 삭제되었습니다.");
        } else if (notification.getTargetType().equals(TargetType.ALL)) {
            // targetType이 'ALL'인 경우, 해당 유저에 대한 알림만 삭제
            receiverRepo.delete(nr);  // 특정 유저의 NotificationReceiver 삭제
            response.put("message", "알림이 삭제되었습니다.");
        } else {
            response.put("message", "알림 삭제에 실패했습니다.");
        }
        return response;
    }
}
