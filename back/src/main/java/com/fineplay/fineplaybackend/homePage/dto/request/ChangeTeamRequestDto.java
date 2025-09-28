package com.fineplay.fineplaybackend.homePage.dto.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ChangeTeamRequestDto {
    private Long userId;
    private Long teamId;
}
