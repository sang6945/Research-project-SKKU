package com.fineplay.fineplaybackend.team.repository;

import com.fineplay.fineplaybackend.team.entity.TeamStatEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TeamStatRepository extends JpaRepository<TeamStatEntity, Long> {
    Optional<TeamStatEntity> findByTeamId(Long teamId);
    long countByTeamOVRGreaterThan(int teamOvr);
}
