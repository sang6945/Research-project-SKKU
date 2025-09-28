package com.fineplay.fineplaybackend.setting.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AlarmUpdateRequestDto {
    private String type;   // "matchAlarm" 또는 "communityAlarm"
    private Boolean value; // true 또는 false
}