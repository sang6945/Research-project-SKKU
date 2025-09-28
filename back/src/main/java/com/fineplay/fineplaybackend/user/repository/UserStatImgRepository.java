package com.fineplay.fineplaybackend.user.repository;

import com.fineplay.fineplaybackend.user.entity.UserStatImgEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserStatImgRepository extends JpaRepository<UserStatImgEntity, Long> {
    Optional<UserStatImgEntity> findByUserId(Long userId);
}
