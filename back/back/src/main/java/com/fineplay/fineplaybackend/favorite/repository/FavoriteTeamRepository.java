package com.fineplay.fineplaybackend.favorite.repository;

import com.fineplay.fineplaybackend.favorite.entity.FavoriteTeamEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FavoriteTeamRepository extends JpaRepository<FavoriteTeamEntity, Long> {
}
