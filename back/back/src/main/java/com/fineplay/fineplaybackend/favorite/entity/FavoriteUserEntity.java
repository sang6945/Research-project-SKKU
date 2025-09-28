package com.fineplay.fineplaybackend.favorite.entity;

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
@Entity(name="favorite_user")
@Table(name="favorite_user")
public class FavoriteUserEntity {

    public FavoriteUserEntity(UserEntity userId, UserEntity favoriteUserId) {
        this.userId = userId;
        this.favoriteUserId = favoriteUserId;
    }

    @Id @GeneratedValue(strategy= GenerationType.IDENTITY)
    private Long favUserTableId;

    @ManyToOne
    @JoinColumn(name = "userId", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private UserEntity userId;

    @ManyToOne
    @JoinColumn(name = "favoriteUserId", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private UserEntity favoriteUserId;
}
