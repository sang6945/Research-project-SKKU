package com.fineplay.fineplaybackend.team.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class TeamMemberListResponseDto {
    private Long userId;
    private boolean leader;
    private String nickName;
    private String OVR;
}
