package com.fineplay.fineplaybackend.match.repository;

import com.fineplay.fineplaybackend.match.entity.MatchReportEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MatchReportRepository extends JpaRepository<MatchReportEntity, Long> {
}
