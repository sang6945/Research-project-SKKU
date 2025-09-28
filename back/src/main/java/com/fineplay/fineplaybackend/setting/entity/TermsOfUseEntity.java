package com.fineplay.fineplaybackend.setting.entity;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import jakarta.persistence.*;
import lombok.*;
@Entity
@Table(name = "terms_of_use")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TermsOfUseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(nullable = false)
    private String createdAt;

    // 관리자 작성자
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "userId")
    private UserEntity author;
}


