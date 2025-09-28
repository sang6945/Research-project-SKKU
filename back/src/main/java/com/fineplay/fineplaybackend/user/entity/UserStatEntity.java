package com.fineplay.fineplaybackend.user.entity;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="user_stat")
@Table(name="user_stat")
public class UserStatEntity {
    @Id
    private Long userId;

    @OneToOne
    @MapsId
    @JoinColumn(name = "userId")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private UserEntity user;

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

    @Column(columnDefinition = "INT DEFAULT 0")
    private int OVR;

    @Column(columnDefinition = "VARCHAR(255) DEFAULT 'CRO'")
    private String selectedStat;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int FWPlayGame;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int MFPlayGame;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int DFPlayGame;

    @Column(columnDefinition = "INT DEFAULT 0")
    private int totalPlayGame;

    public UserStatEntity(UserEntity user) {
        this.user = user;
        this.SPD = 0;
        this.PAS = 0;
        this.PAC = 0;
        this.SHO = 0;
        this.DRV = 0;
        this.DEC = 0;
        this.DRI = 0;
        this.TAC = 0;
        this.BLD = 0;
        this.CRO = 0;
        this.HED = 0;
        this.FST = 0;
        this.ACT = 0;
        this.OFF = 0;
        this.TEC = 0;
        this.COP = 0;
        this.OVR = 0;
        this.FWPlayGame = 0;
        this.MFPlayGame = 0;
        this.DFPlayGame = 0;
        this.totalPlayGame = 0;

        //this.selectedStat = "CRO";


    }

}

