package com.fineplay.fineplaybackend.setting.dto.response;

import lombok.*;


@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class AlarmResponseDto {

    private boolean matchAlarm;
    private boolean communityAlarm;
    private String message;
    private String errCode;

    public static AlarmResponseDto success(boolean matchAlarm, boolean communityAlarm) {
        return new AlarmResponseDto(
                matchAlarm,
                communityAlarm,
                "알림 설정이 성공적으로 변경되었습니다.",
                null
        );
    }

    public static AlarmResponseDto error(String errCode) {
        return new AlarmResponseDto(
                false,
                false,
                "알림 설정 변경에 실패했습니다.",
                errCode
        );
    }
}
