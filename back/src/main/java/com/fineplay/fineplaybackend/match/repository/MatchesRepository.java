package com.fineplay.fineplaybackend.match.repository;

import com.fineplay.fineplaybackend.match.entity.MatchesEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MatchesRepository extends JpaRepository<MatchesEntity, Long> {
    List<MatchesEntity> findTop15ByHomeTeamIdOrAwayTeamIdOrderByMatchDateDesc(Long homeId, Long awayId);
    List<MatchesEntity> findTop5ByHomeTeamIdOrAwayTeamIdOrderByMatchDateDesc(Long homeId, Long awayId);
    List<MatchesEntity> findByHomeTeamIdOrAwayTeamIdOrderByMatchDateDesc(Long homeId, Long awayId);
}

