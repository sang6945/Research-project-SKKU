package com.fineplay.fineplaybackend.setting.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class PasswordCheckResponseDto {
    private boolean isPasswordCorrect;
    private String errCode;

    public static PasswordCheckResponseDto success() {
        return new PasswordCheckResponseDto(true, null);
    }

    public static PasswordCheckResponseDto error(String errCode) {
        return new PasswordCheckResponseDto(false, errCode);
    }
}
