package com.fineplay.fineplaybackend.auth.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class CheckNickDuplicateResponseDto {

    private String status;  // "EXISTS" 또는 "NOT_EXISTS"
    private String message; // 예: "닉네임 중복 여부 확인"

    public static CheckNickDuplicateResponseDto exists() {
        return new CheckNickDuplicateResponseDto("EXISTS", "닉네임이 이미 존재합니다.");
    }

    public static CheckNickDuplicateResponseDto notExists() {
        return new CheckNickDuplicateResponseDto("NOT_EXISTS", "사용 가능한 닉네임입니다.");
    }
}
