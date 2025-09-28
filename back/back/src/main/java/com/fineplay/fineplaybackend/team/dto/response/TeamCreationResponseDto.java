package com.fineplay.fineplaybackend.team.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TeamCreationResponseDto {
    // 팀 생성 결과 에러 코드 (null이면 성공)
    private String errCode;
}
