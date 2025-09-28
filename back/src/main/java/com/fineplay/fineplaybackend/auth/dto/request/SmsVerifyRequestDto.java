package com.fineplay.fineplaybackend.auth.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SmsVerifyRequestDto {
    @NotNull(message = "휴대폰 번호를 입력해주세요.")
    private String phoneNum;
    @NotNull(message = "인증번호를 입력해주세요.")
    private String certificationCode;
}