//package com.fineplay.fineplaybackend.playerSearch.repository;
//
//import com.fineplay.fineplaybackend.auth.entity.UserEntity;
//import com.fineplay.fineplaybackend.playerSearch.entity.SearchHistoryEntity;
//import org.springframework.data.jpa.repository.JpaRepository;
//import java.util.List;
//
//public interface SearchHistoryRepository extends JpaRepository<SearchHistoryEntity, Long> {
//    List<SearchHistoryEntity> findByUserOrderByCreatedAtDesc(UserEntity user);
//}
