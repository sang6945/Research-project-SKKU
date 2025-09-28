package com.fineplay.fineplaybackend.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CheckEmailDuplicateRequestDto {

    @NotNull(message = "이메일은 필수입니다.")
    @Email(message = "유효한 이메일을 입력해주세요.")
    private String email;
}
