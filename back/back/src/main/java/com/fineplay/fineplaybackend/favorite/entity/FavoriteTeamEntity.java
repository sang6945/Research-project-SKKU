package com.fineplay.fineplaybackend.favorite.entity;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.team.entity.TeamEntity;
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
@Entity(name="favorite_team")
@Table(name="favorite_team")
public class FavoriteTeamEntity {
    @Id
    @GeneratedValue(strategy= GenerationType.IDENTITY)
    private Long favTeamTableId;

    @ManyToOne
    @JoinColumn(name = "userId", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private UserEntity userId;

    @ManyToOne
    @JoinColumn(name = "favoriteTeamId", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private TeamEntity favoriteTeamId;
}
