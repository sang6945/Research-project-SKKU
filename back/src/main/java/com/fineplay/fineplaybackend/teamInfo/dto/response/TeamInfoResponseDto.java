package com.fineplay.fineplaybackend.teamInfo.dto.response;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Data

public class TeamInfoResponseDto {
    private int status;
    private String responseMessage;
    private String teamName;
    private String OVR;
    private String ovrPercent;
    private String recentWin15;
    private String recentDraw15;
    private String recentLose15;
    private String homeTown;
    private String memberNum;
    private String sports;
    private String teamRegister;
    private String OVR_dist;
    private String FW;
    private String DF;
    private String MF;
    private String SPD;
    private String PAS;
    private String PAC;
    private String teamImg;
    private String totalWin;
    private String totalDraw;
    private String totalLose;
    private String winningRate;
    private List<MatchResultDto> matchResultList;
    private List<StatDistributionDto> statDistribution;

    @Data
    public static class MatchResultDto {
        private String date;
        private String result;
        private String hometeam;
        private String awayteam;
        private String homeScore;
        private String awayScore;
        private String matchId;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class StatDistributionDto {
        /** 구간 라벨 (예: "0-10") */
        private String range;
        /** 해당 구간에 속한 FW(공격수) 인원 수 */
        private int fwCount;
        /** 해당 구간에 속한 MF(미드필더) 인원 수 */
        private int mfCount;
        /** 해당 구간에 속한 DF(수비수) 인원 수 */
        private int dfCount;
    }
}
