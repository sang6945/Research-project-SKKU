package com.fineplay.fineplaybackend.setting.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor

public class NoticeResponseDto {

    private Long id;
    private String title;
    private String content;
    private String createdAt;
    private String errCode;


    public NoticeResponseDto(Long id, String title, String content, String createdAt) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.createdAt = createdAt;
    }


    // 에러 응답 생성자
    public static NoticeResponseDto error(String errCode) {
        NoticeResponseDto dto = new NoticeResponseDto();
        dto.id = -1L; // 프론트에서 에러 응답 여부 구분 가능
        dto.title = "";
        dto.content = "";
        dto.createdAt = "";
        dto.errCode = errCode != null ? errCode : "UNKNOWN_ERROR";
        return dto;
    }
}