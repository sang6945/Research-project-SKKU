package com.fineplay.fineplaybackend.teamInfo.controller;

import com.fineplay.fineplaybackend.teamInfo.dto.request.*;
import com.fineplay.fineplaybackend.teamInfo.dto.response.*;
import com.fineplay.fineplaybackend.teamInfo.service.TeamInfoService;
import com.fineplay.fineplaybackend.provider.JwtProvider;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/teamInfo")
public class TeamInfoController {
    private final TeamInfoService teamInfoService;
    private final JwtProvider jwtProvider;

    @Autowired
    public TeamInfoController(TeamInfoService teamInfoService, JwtProvider jwtProvider) {
        this.teamInfoService = teamInfoService;
        this.jwtProvider = jwtProvider;
    }

    // ✅ 1. 팀정보 접근 (userId,teamId를 요청 Body에서 받음)
    @PostMapping
    public TeamInfoResponseDto getTeamInfo(HttpServletRequest request,
                                           @RequestBody TeamInfoRequestDto requestDto)
    {
        validateToken(request); // JWT 유효성만 검증
        Long tokenUserId = jwtProvider.getUserIdFromRequest(request);
        return teamInfoService.getTeamInfo(tokenUserId,requestDto.getUserId(), requestDto.getTeamId());
    }


    // ✅ 2. 더보기 버튼 클릭 - 해당팀의 모든 매치 정보 (userId,teamId를 요청 Body에서 받음)
    @PostMapping("/AllMatch")
    public AllMatchResponseDto getAllMatches(HttpServletRequest request,
                                           @RequestBody AllMatchRequestDto requestDto)
    {
        validateToken(request); // JWT 유효성만 검증
        return teamInfoService.getAllMatches(requestDto.getTeamId());
    }

    // ✅ 3. 매치 정보 조회
    @PostMapping("/MatchInfo")
    public MatchInfoResponseDto getMatchInfo(HttpServletRequest request,
                                             @RequestBody MatchInfoRequestDto requestDto)
    {
        validateToken(request); // JWT 유효성만 검증
        return teamInfoService.getMatchInfo(requestDto.getUserId(),requestDto.getTeamId(),requestDto.getMatchId());
    }

    // ✅ 4. 매치 세부 정보
    @PostMapping("/MatchInfo/MatchDetail")
    public MatchDetailResponseDto getMatchDetail(HttpServletRequest request,
                                             @RequestBody MatchDetailRequestDto requestDto)
    {
        validateToken(request); // JWT 유효성만 검증
        return teamInfoService.getMatchDetail(requestDto.getTeamId(),requestDto.getMatchId());
    }




    // ✅ 기존 JwtProvider의 메서드를 활용하여 JWT 유효성만 검증
    private void validateToken(HttpServletRequest request)
    {
        String token = jwtProvider.getTokenFromRequest(request);
        System.out.println("🔐 토큰: " + token);
        if (token == null) {
            throw new RuntimeException("JWT Token not found in request");
        }
        jwtProvider.validateJwt(token); // ✅ JWT가 유효한지만 확인
    }


}
