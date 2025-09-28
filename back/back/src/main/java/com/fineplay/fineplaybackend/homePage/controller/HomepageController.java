package com.fineplay.fineplaybackend.homePage.controller;

import com.fineplay.fineplaybackend.homePage.dto.request.*;
import com.fineplay.fineplaybackend.homePage.dto.response.*;
import com.fineplay.fineplaybackend.homePage.service.HomepageService;
import com.fineplay.fineplaybackend.provider.JwtProvider;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/home")
public class HomepageController {
    private final HomepageService homepageService;
    private final JwtProvider jwtProvider;

    @Autowired
    public HomepageController(HomepageService homepageService, JwtProvider jwtProvider) {
        this.homepageService = homepageService;
        this.jwtProvider = jwtProvider;
    }

    // ✅ 1. 홈페이지 접근 (userId를 요청 Body에서 받음)
    @PostMapping
    public HomepageResponseDto getHomePage(HttpServletRequest request,
                                           @RequestBody HomepageRequestDto requestDto)
    {
        validateToken(request); // JWT 유효성만 검증
        return homepageService.getHomePage(requestDto.getUserId());
    }

    // ✅ 2. 팀 선택 토글클릭 (userId를 요청 Body에서 받음)
    @PostMapping("/TeamList")
    public TeamListResponseDto getTeamList(HttpServletRequest request,
                                           @RequestBody TeamListRequestDto requestDto)
    {
        validateToken(request); // JWT 유효성만 검증
        return homepageService.getTeamList(requestDto.getUserId());
    }

    // ✅ 3. Current팀 변경 및 해당 팀 정보
    @PostMapping("/ChangeTeam")
    public ChangeTeamResponseDto changeTeam(HttpServletRequest request,
                                            @RequestBody ChangeTeamRequestDto requestDto) {
        validateToken(request); // JWT 유효성만 검증
        Long tokenUserId = jwtProvider.getUserIdFromRequest(request);
        return homepageService.changeTeam(tokenUserId,requestDto.getUserId(), requestDto.getTeamId());
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

    @PostMapping("/TeamCurrent")
    public TeamCurrentResponseDto getCurrentTeam(HttpServletRequest request, @RequestBody TeamCurrentRequestDto requestDto) {
        validateToken(request);

        return homepageService.getCurrentTeam(requestDto);
    }

}
