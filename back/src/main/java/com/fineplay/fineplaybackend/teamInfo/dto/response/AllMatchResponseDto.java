package com.fineplay.fineplaybackend.teamInfo.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Data
public class AllMatchResponseDto {
    private int status;
    private String responseMessage;
    private List<MatchResultDto> matchResultList;

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
}
