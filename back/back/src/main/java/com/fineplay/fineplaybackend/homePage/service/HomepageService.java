package com.fineplay.fineplaybackend.homePage.service;

import com.fineplay.fineplaybackend.homePage.dto.response.*;
import com.fineplay.fineplaybackend.homePage.dto.request.*;

public interface HomepageService {
    /**
     * 홈페이지 기본정보
     * @param userId 사용자 ID
     * @return 마이페이지 응답 DTO
     */
    HomepageResponseDto getHomePage(Long userId);

    /**
     * 사용자가 가입한(또는 참여 중인) 팀 목록 조회
     */
    TeamListResponseDto getTeamList(Long userId);

    /**
     * Current Team변경 및 해당 팀 정보 조회
     */
    ChangeTeamResponseDto changeTeam(Long tokenUserId, Long userId, Long teamId);

    TeamCurrentResponseDto getCurrentTeam(TeamCurrentRequestDto requestDto);
}
