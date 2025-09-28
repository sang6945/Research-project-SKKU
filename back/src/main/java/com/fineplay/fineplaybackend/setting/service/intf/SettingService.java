package com.fineplay.fineplaybackend.setting.service.intf;

import com.fineplay.fineplaybackend.setting.dto.request.*;
import com.fineplay.fineplaybackend.setting.dto.response.*;
import org.springframework.http.ResponseEntity;


import java.util.List;

public interface SettingService {

    ResponseEntity<? super EditProfileResponseDto> updateProfile(EditProfileRequestDto request);
    ResponseEntity<? super EditPasswordResponseDto> updatePassword(EditPasswordRequestDto request);
    ResponseEntity<? super PasswordCheckResponseDto> checkPassword(PasswordCheckRequestDto request);
    ResponseEntity<? super EditProfileResponseDto> withdrawUser(String email);

    // 🔔 알람 - userId 기반으로 토큰 인증은 Controller에서 수행
    ResponseEntity<? super AlarmResponseDto> updateMatchAlarm(Long userId, AlarmRequestDto request);
    ResponseEntity<? super AlarmResponseDto> updateCommunityAlarm(Long userId, AlarmRequestDto request);

    // ✅ 공지사항은 여러 개 반환되므로 List로 수정
    // SettingService.java
    ResponseEntity<List<NoticeResponseDto>> getNotice();
    ResponseEntity<NoticeResponseDto> getNoticeById(Long id);



    ResponseEntity<? super TermsOfUseResponseDto> getTermsOfUse();
    ResponseEntity<? super ReportBugsResponseDto> getReportBugs();
}