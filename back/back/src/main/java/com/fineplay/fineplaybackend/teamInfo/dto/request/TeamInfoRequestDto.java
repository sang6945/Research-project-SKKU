package com.fineplay.fineplaybackend.teamInfo.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class TeamInfoRequestDto {
    private Long teamId;
    private Long userId;
}
