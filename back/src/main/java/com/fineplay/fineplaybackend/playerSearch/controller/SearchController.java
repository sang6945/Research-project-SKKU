package com.fineplay.fineplaybackend.playerSearch.controller;


import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
import com.fineplay.fineplaybackend.provider.JwtProvider;
import com.fineplay.fineplaybackend.playerSearch.dto.response.UserSearchResponseDto;
import com.fineplay.fineplaybackend.playerSearch.dto.request.UserSearchRequestDto;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/search")
public class SearchController {

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;

    public SearchController(UserRepository userRepository, JwtProvider jwtProvider) {
        this.userRepository = userRepository;
        this.jwtProvider = jwtProvider;
    }

    // ✅ 닉네임으로 유저 검색 (POST + JSON Body, JWT 인증 필요)
    @PostMapping("/users")
    public ResponseEntity<?> searchUsersWithJson(
            @RequestBody UserSearchRequestDto request,
            HttpServletRequest httpRequest) {

        // 🔹 토큰 인증
        String token = jwtProvider.getTokenFromRequest(httpRequest);
        if (token == null) return ResponseEntity.status(401).body("인증 실패: 토큰이 없습니다.");

        String email = jwtProvider.validateJwt(token);
        if (email == null) return ResponseEntity.status(403).body("인증 실패: 유효하지 않은 토큰입니다.");

        UserEntity user = userRepository.findByEmail(email);
        if (user == null) return ResponseEntity.status(404).body("사용자를 찾을 수 없습니다.");

        // 🔹 일부 포함된 닉네임 검색 (like '%입력값%')
        List<UserEntity> foundUsers = userRepository.findByNickNameContaining(request.getNickname());

        List<UserSearchResponseDto> result = foundUsers.stream()
                .map(u -> new UserSearchResponseDto(u.getUserId(), u.getNickName()))
                .toList();

        return ResponseEntity.ok(result);
    }



}































