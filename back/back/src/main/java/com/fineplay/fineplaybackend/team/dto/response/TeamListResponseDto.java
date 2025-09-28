package com.fineplay.fineplaybackend.team.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import java.util.List;

@Getter
@AllArgsConstructor
public class TeamListResponseDto {
    private int statusCode;
    private String responseMessage;
    private List<TeamResponseDto> data;
    private boolean hasUnreadNotification;
}
