package com.fineplay.fineplaybackend.favorite.repository;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.favorite.entity.FavoriteUserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteUserRepository extends JpaRepository<FavoriteUserEntity, Long> {
    boolean existsByUserIdAndFavoriteUserId(UserEntity userId, UserEntity favoriteUserId);

    Optional<FavoriteUserEntity> findByUserIdAndFavoriteUserId(UserEntity userId, UserEntity favoriteUserId);

    List<FavoriteUserEntity> findByUserId(UserEntity userId);
}
