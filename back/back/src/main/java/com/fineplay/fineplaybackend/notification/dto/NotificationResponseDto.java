package com.fineplay.fineplaybackend.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationResponseDto {

    private Long id;                    // 알림 ID
    private String type;                // 알림 타입 (예: "REQUEST_RESULT", "NEW_MATCH")
    private String title;               // 알림 제목
    private String content;             // 알림 내용
    private String createdAt;           // 알림 생성일 (LocalDateTime을 String 형식으로 변환하여 반환)
    private Long userId;                // 알림을 받는 유저의 ID
    private Long teamId;                // 팀 가입 관련 알림일 경우 teamId
    private Long matchId;               // 새 경기 등록 관련 알림일 경우 matchId
    private String status;              // 알림 상태 (예: "new", "read")
}