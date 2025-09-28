package com.fineplay.fineplaybackend.team.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class TeamResponseDto {
    private Long teamId;
    private String teamName;
    private String teamImg;
    private String OVR;
    private String Win;
    private String Draw;
    private String Lose;
    private String HomeTown1;
    private String MemberNum;
    private String Sports;
    private boolean isLeader;
}
