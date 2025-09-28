package com.fineplay.fineplaybackend.teamInfo.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchDetailResponseDto {
    private int statusCode;
    private String responseMessage;

    private String HomeTeamName;
    private String AwayTeamName;

    private TeamDetail Home;
    private TeamDetail Away;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TeamDetail {
        private String Score;
        private String Shooting;
        private String OnTarget;
        private String Possession;
        private String Pass;
        private String Tackle;
        private String Foul;
        private String Card;
        private String Rating;
    }
}