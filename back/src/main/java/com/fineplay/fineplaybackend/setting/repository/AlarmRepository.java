package com.fineplay.fineplaybackend.setting.repository;

import com.fineplay.fineplaybackend.setting.dto.request.AlarmRequestDto;
import com.fineplay.fineplaybackend.setting.dto.response.AlarmResponseDto;
import org.springframework.http.ResponseEntity;

public interface AlarmRepository {

    // ✅ 추가
    ResponseEntity<? super AlarmResponseDto> updateMatchAlarm(AlarmRequestDto request);
    ResponseEntity<? super AlarmResponseDto> updateCommunityAlarm(AlarmRequestDto request);

}
