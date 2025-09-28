package com.fineplay.fineplaybackend.auth.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class CheckEmailDuplicateResponseDto {

    private String status;  // "EXISTS" 또는 "NOT_EXISTS"
    private String message; // 예: "이메일 중복 여부 확인"

    public static CheckEmailDuplicateResponseDto exists() {
        return new CheckEmailDuplicateResponseDto("EXISTS", "이메일이 이미 존재합니다.");
    }

    public static CheckEmailDuplicateResponseDto notExists() {
        return new CheckEmailDuplicateResponseDto("NOT_EXISTS", "사용 가능한 이메일입니다.");
    }
}
