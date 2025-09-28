package com.fineplay.fineplaybackend.team.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TeamJoinActionDto {
    private Long teamId;
    private Long userId;
}
