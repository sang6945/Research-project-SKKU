package com.fineplay.fineplaybackend.auth.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CheckNickDuplicateRequestDto {

    @NotNull(message = "닉네임은 필수입니다.")
    private String nickName;
}
