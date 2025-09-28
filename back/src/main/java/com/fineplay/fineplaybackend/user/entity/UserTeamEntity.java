package com.fineplay.fineplaybackend.user.entity;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.team.entity.TeamEntity;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity(name="user_team")
@Table(name="user_team")
@IdClass(UserTeamId.class)
public class UserTeamEntity {
    @Id
    private Long userId;

    @Id
    private Long teamId;

    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "userId")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private UserEntity user;

    @ManyToOne
    @MapsId("teamId")
    @JoinColumn(name = "teamId")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private TeamEntity team;

    private boolean isCurrent;

    public void setCurrent(boolean current) {
        this.isCurrent = current;
    }

    // getter
    // 새로 추가
    @Column(name = "joined_at", nullable = true, updatable = false)
    private LocalDateTime joinedAt;

    // 생성자 또는 @PrePersist로 값 세팅
    @PrePersist
    public void prePersist() {
        this.joinedAt = LocalDateTime.now();
    }

}
