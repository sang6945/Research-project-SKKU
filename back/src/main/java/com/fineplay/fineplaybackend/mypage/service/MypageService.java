package com.fineplay.fineplaybackend.mypage.service;

import com.fineplay.fineplaybackend.mypage.dto.response.MypageProfileResponseDto;
import com.fineplay.fineplaybackend.mypage.dto.request.SelectedStatRequestDto;
import com.fineplay.fineplaybackend.mypage.dto.response.SelectedStatResponseDto;
import com.fineplay.fineplaybackend.mypage.dto.request.PageMoveRequestDto;
import com.fineplay.fineplaybackend.mypage.dto.response.PageMoveResponseDto;

public interface MypageService {

    /**
     * 마이페이지 기본 정보 조회
     * @param userId 사용자 ID
     * @return 마이페이지 응답 DTO
     */
    MypageProfileResponseDto getMypageProfile(Long userId);

    /**
     * 선택된 스탯 저장
     * @param tokenUserId 토큰에서 추출한 사용자 ID (보안 확인용)
     * @param requestDto 선택된 스탯 정보
     * @return 처리 결과 DTO
     */
    SelectedStatResponseDto updateSelectedStat(Long tokenUserId, SelectedStatRequestDto requestDto);

    /**
     * 특정 스탯 페이지 이동 요청 (이미지 URL 반환)
     * @param statName 페이지 스킬명 (예: SPD, PAC)
     * @param requestDto 사용자 ID 포함
     * @return 이미지 경로 DTO
     */
    PageMoveResponseDto movePage(String statName, PageMoveRequestDto requestDto);
}