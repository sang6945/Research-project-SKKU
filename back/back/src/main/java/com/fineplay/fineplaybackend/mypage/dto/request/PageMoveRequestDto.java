package com.fineplay.fineplaybackend.mypage.dto.request;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PageMoveRequestDto {
    private Long userId;
    private String pageSkillName;  // 예: "pac", "spd", "pas", "dri", "dec"
}
