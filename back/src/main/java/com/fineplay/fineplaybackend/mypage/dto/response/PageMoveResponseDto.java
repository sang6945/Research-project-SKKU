package com.fineplay.fineplaybackend.mypage.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PageMoveResponseDto {
    private int status;
    private String msg;
    private String img;
    private boolean hasUnreadNotification;// 스탯 관련 이미지 경로 또는 URL
}
