package com.fineplay.fineplaybackend.team.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class TeamSearchResponseDto {
    private String teamName;
    private Long teamId;
}
