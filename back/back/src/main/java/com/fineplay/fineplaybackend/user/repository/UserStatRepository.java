package com.fineplay.fineplaybackend.user.repository;

import com.fineplay.fineplaybackend.user.entity.UserStatEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserStatRepository extends JpaRepository<UserStatEntity, Long> {
    Optional<UserStatEntity> findByUserId(Long userId);
    long countByOVRGreaterThan(int ovr);
}
