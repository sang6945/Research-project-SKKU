package com.fineplay.fineplaybackend.setting.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor

public class SettingStatusDto {
    private boolean matchAlarm;
    private boolean communityAlarm;
}
