package com.fineplay.fineplaybackend.notification.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notification")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String type;  // 알림의 종류 (예: "REQUEST_RESULT", "NEW_MATCH", 등)

    private String title;  // 알림 제목
    private String content;  // 알림 내용

    @Enumerated(EnumType.STRING)  // enum 값을 데이터베이스에 저장
    @Column(name = "target_type")
    private TargetType targetType;  // 알림을 받을 대상 타입 (all 또는 user)

    @Column(name = "target_id")
    private Long targetId;  // 알림을 받을 대상 ID (예: userId, teamId)

    @Column(name = "team_id")
    private Long teamId;               // 팀 가입 관련 알림일 경우 사용

    @Column(name = "match_id")
    private Long matchId;              // 새 경기 등록 관련 알림일 경우 사용

    @Column(name = "created_at", updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
