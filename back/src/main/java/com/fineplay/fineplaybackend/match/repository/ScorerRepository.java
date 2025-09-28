package com.fineplay.fineplaybackend.match.repository;

import com.fineplay.fineplaybackend.match.entity.ScorerEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScorerRepository extends JpaRepository<ScorerEntity, Long> {
    List<ScorerEntity> findByMatches_MatchIdAndIsHome(Long matchId, Boolean isHome);
}