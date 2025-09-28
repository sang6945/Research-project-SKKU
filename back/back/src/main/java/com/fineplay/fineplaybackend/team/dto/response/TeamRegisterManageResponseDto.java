package com.fineplay.fineplaybackend.team.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class TeamRegisterManageResponseDto {
    private String userName;
    private String position;
    private String OVR;
    private Long userId;
}
