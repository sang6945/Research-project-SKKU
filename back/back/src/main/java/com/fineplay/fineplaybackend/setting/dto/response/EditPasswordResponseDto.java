package com.fineplay.fineplaybackend.setting.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class EditPasswordResponseDto {
    private String message;
    private String errCode;

    public static EditPasswordResponseDto success() {
        return new EditPasswordResponseDto("비밀번호가 성공적으로 변경되었습니다.", null);
    }

    public static EditPasswordResponseDto error(String message, String errCode) {
        return new EditPasswordResponseDto(message, errCode);
    }
}
