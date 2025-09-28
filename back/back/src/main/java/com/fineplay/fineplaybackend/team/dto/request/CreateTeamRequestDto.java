package com.fineplay.fineplaybackend.team.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateTeamRequestDto {

    @NotBlank(message = "팀 이름은 필수입니다.")
    private String teamName;

    @NotBlank(message = "첫 번째 지역은 필수입니다.")
    private String homeTown1;
    @NotBlank(message = "HomeTown2(두 번째 지역 정보)은 공백일 수 없습니다.")
    private String homeTown2;

    @NotBlank(message = "종목을 입력해주세요.")
    private String sports;


    private Boolean autoAccept;

    // ✅ userId 필드 제거 (JWT에서 가져오기 때문)
}

