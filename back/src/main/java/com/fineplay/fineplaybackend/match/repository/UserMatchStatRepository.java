package com.fineplay.fineplaybackend.match.repository;

import com.fineplay.fineplaybackend.match.entity.UserMatchId;
import com.fineplay.fineplaybackend.match.entity.UserMatchStatEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserMatchStatRepository extends JpaRepository<UserMatchStatEntity, UserMatchId> {
    Optional<UserMatchStatEntity> findByUserIdAndMatchId(Long userId, Long matchId);
}
