package com.fineplay.fineplaybackend.setting.service.intf;

import com.fineplay.fineplaybackend.setting.dto.response.TermsOfUseResponseDto;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface TermsOfUseService {

    // 모든 약관 목록 반환
    ResponseEntity<List<TermsOfUseResponseDto>> getAllTermsOfUse();

    // 특정 약관 ID 기준 조회
    ResponseEntity<TermsOfUseResponseDto> getTermsOfUseById(Long id);

    // 특정 약관 버전 기준 조회 (선택적)
    ResponseEntity<TermsOfUseResponseDto> getTermsOfUseByVersion(String version);
}
