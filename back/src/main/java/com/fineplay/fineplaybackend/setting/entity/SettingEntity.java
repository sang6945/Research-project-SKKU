package com.fineplay.fineplaybackend.setting.entity;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Entity
@Table(name = "user_setting")
@Getter
@Setter
@NoArgsConstructor
public class SettingEntity {

    @Id
    private Long userId;  // PK = FK

    @OneToOne
    @MapsId  // FK이자 PK로 사용
    @JoinColumn(name = "user_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private UserEntity user;

    @Column(name = "match_alarm", nullable = false)
    private boolean matchAlarm = false;

    @Column(name = "community_alarm", nullable = false)
    private boolean communityAlarm = false;

    public SettingEntity(UserEntity user, boolean matchAlarm, boolean communityAlarm) {
        this.user = user;
        this.matchAlarm = matchAlarm;
        this.communityAlarm = communityAlarm;
    }
}
