package com.fineplay.fineplaybackend.homePage.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ChangeTeamResponseDto {
    private final int status;
    private final String currentTeam;
    private final String teamImg;
    private final String win;
    private final String draw;
    private final String lose;
    private final String fw;
    private final String mf;
    private final String df;
}
