package com.fineplay.fineplaybackend.homePage.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class TeamListResponseDto {
    /**
     * HTTP 상태 코드 (200)
     */
    private final int status;

    /**
     * 내가 소속된 팀 리스트
     */
    private final List<TeamDto> MyTeamList;

    @Getter
    @AllArgsConstructor
    public static class TeamDto {
        /** 팀 ID */
        private final Long TeamId;

        /** 팀 이름 */
        private final String TeamName;
    }
}

