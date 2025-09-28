package com.fineplay.fineplaybackend.notification.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notification_receiver")
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class NotificationReceiver {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "notification_id")
    private Notification notification;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "is_read")
    @Builder.Default
    private Boolean isRead = false;


    private LocalDateTime readAt;
}
