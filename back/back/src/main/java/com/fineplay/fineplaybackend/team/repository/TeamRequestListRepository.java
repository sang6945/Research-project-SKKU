package com.fineplay.fineplaybackend.team.repository;

import com.fineplay.fineplaybackend.team.entity.TeamRequestListEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TeamRequestListRepository extends JpaRepository<TeamRequestListEntity, Long> {



    // ✅ 특정 팀의 모든 가입 요청 조회 (status 필요 없음)
    List<TeamRequestListEntity> findByTeam_TeamId(Long teamId);

    // ✅ 특정 팀 가입 요청 조회 (userId, teamId 기준)
    Optional<TeamRequestListEntity> findByTeam_TeamIdAndUser_UserId(Long teamId, Long userId);

    // ✅ 특정 팀 가입 요청 삭제 (거절 또는 승인 후)
    void deleteByTeam_TeamIdAndUser_UserId(Long teamId, Long userId);

    // ✅ 특정 유저가 이미 해당 팀에 가입 신청했는지 확인
    boolean existsByTeam_TeamIdAndUser_UserId(Long teamId, Long userId);

    boolean existsByUser_UserIdAndTeam_TeamId(Long userId, Long teamId);

}
