package com.fineplay.fineplaybackend.match.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="match_report")
@Table(name="match_report")
public class MatchReportEntity {

    @Id
    private Long matchId;

    @OneToOne
    @MapsId
    @JoinColumn(name = "matchId")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private MatchesEntity matches;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int homeGoals;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int homeShots;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int homeShotsOnTarget;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int homePossession;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int homePasses;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int homeTackles;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int homeFouls;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int homeCards;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int homeRatings;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayGoals;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayShots;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayShotsOnTarget;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayPossession;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayPasses;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayTackles;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayFouls;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayCards;
    @Column(columnDefinition = "INT DEFAULT 0")
    private int awayRatings;

}
