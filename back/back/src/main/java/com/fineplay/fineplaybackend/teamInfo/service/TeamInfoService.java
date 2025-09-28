package com.fineplay.fineplaybackend.teamInfo.service;

import com.fineplay.fineplaybackend.homePage.dto.response.ChangeTeamResponseDto;
import com.fineplay.fineplaybackend.teamInfo.dto.response.*;


public interface TeamInfoService {
    /**
     * 팀정보 조회
     */
    TeamInfoResponseDto getTeamInfo(Long tokenUserId, Long userId, Long teamId);

    /**
     * 더보기 버튼-모든 매치정보
     */
    AllMatchResponseDto getAllMatches(Long teamId);

    /**
     * 매치정보 조회
     */
    MatchInfoResponseDto getMatchInfo(Long userId, Long teamId, Long matchId);

    /**
     * 매치 세부 정보 조회
     */
    MatchDetailResponseDto getMatchDetail(Long teamId, Long matchId);
}
