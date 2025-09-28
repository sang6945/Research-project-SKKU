//package com.fineplay.fineplaybackend.playerSearch.entity;
//
//import com.fineplay.fineplaybackend.auth.entity.UserEntity;
//import jakarta.persistence.*;
//import lombok.Getter;
//import lombok.NoArgsConstructor;
//import java.time.LocalDateTime;
//
//@Getter
//@NoArgsConstructor
//@Entity
//@Table(name = "search_history_oldversion")
//public class SearchHistoryEntity {
//
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long id;
//
//    @OneToOne
//    @MapsId
//    @JoinColumn(name = "user_id", nullable = false)
//    private UserEntity user;
//
//    @Column(nullable = false)
//    private String searchText;
//
//    @Column(nullable = false)
//    private LocalDateTime createdAt = LocalDateTime.now();
//
//    public SearchHistoryEntity(UserEntity user, String searchText) {
//        this.user = user;
//        this.searchText = searchText;
//        this.createdAt = LocalDateTime.now();
//    }
//}
