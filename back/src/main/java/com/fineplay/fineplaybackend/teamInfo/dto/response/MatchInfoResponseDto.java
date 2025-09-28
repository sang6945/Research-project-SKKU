package com.fineplay.fineplaybackend.teamInfo.dto.response;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchInfoResponseDto {
    private int statusCode;
    private String responseMessage;

    // MatchDetail 필드를 루트에 직접 노출
    private String HomeTeam;
    private String AwayTeam;
    private String HomeTeamScore;
    private String AwayTeamScore;
    private String Match_Date;
    private String location;
    private List<Scorer> HomeTeam_Scorer;
    private List<Scorer> AwayTeam_Scorer;
    private String Formation;
    private String Grade;
    private String Position;
    private String PlayTime;
    private String Score;
    private String Assist;
    private String SelectedStat;

    // 스페셜 스탯 (7개)
    private int CRO;
    private int HED;
    private int FST;
    private int ACT;
    private int OFF;
    private int TEC;
    private int COP;

    // 공통 스탯 (3개)
    private int PAC;
    private int PAS;
    private int SPD;

    // 포지션별 스탯
    private int SHO;
    private int DRV;
    private int DEC;
    private int DRI;
    private int TAC;
    private int BLD;

    @Getter @Setter @NoArgsConstructor @AllArgsConstructor
    public static class Scorer {
        private String Time;
        private String Player;
    }
}
