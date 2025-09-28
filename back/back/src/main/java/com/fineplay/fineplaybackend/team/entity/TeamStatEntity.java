package com.fineplay.fineplaybackend.team.entity;

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
@Entity(name="team_stat")
@Table(name="team_stat")
public class TeamStatEntity {
    @Id
    private Long teamId;

    @OneToOne
    @MapsId
    @JoinColumn(name = "teamId", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private TeamEntity team;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int FW;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int DF;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int MF;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int SPD;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int PAS;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int PAC;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int teamOVR;

    // 기본값을 0으로 설정하는 생성자 추가
    public TeamStatEntity(TeamEntity team) {
        this.team = team;
        this.FW = 0;
        this.DF = 0;
        this.MF = 0;
        this.SPD = 0;
        this.PAS = 0;
        this.PAC = 0;
        this.teamOVR = 0;
    }
}
