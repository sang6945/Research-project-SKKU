package com.fineplay.fineplaybackend.setting.dto.request;

import lombok.*;


@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter

public class AlarmRequestDto {
    private long userId;
    private String email;  // 🔹 이메일 추가
    private Boolean matchAlarm;
    private Boolean communityAlarm;
}

