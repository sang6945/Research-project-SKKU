package com.fineplay.fineplaybackend.team.entity;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="team_request_list")
@Table(name="team_request_list")
public class TeamRequestListEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long requestListId;

    @ManyToOne
    @JoinColumn(name = "userId", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private UserEntity user;

    @ManyToOne
    @JoinColumn(name = "teamId", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private TeamEntity team;
}
