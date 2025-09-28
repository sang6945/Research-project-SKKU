package com.fineplay.fineplaybackend.team.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TeamNameDuplicateResponseDto {
    // 팀 이름 사용 가능 여부
    private Boolean useable;
    // 에러 코드 (문제가 없으면 null)
    private String errCode;
}
