package com.fineplay.fineplaybackend.match.entity;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="user_match_stat")
@Table(name="user_match_stat")
@IdClass(UserMatchId.class)
public class UserMatchStatEntity {

    @Id
    private Long userId;

    @Id
    private Long matchId;

    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "userId")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private UserEntity user;

    @ManyToOne
    @MapsId("matchId")
    @JoinColumn(name = "matchId")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private MatchesEntity matches;

    private String matchPosition;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int SPD;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int PAS;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int PAC;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int SHO;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int DRV;

    @Column(name = "`DEC`", columnDefinition = "INT DEFAULT 0")
    private int DEC;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int DRI;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int TAC;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int BLD;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int CRO;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int HED;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int FST;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int ACT;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int OFF;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int TEC;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int COP;

    private int runTime;

    private int score;

    private int assist;

    private double rating;
}
