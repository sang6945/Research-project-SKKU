package com.fineplay.fineplaybackend.user.controller;

import com.fineplay.fineplaybackend.user.dto.request.PatchNicknameRequestDto;
import com.fineplay.fineplaybackend.user.dto.request.PatchPositionRequestDto;
import com.fineplay.fineplaybackend.user.dto.request.VerifyPasswordRequestDto;
import com.fineplay.fineplaybackend.user.dto.response.DeleteUserResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.GetSignInUserResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.GetUserStatResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.PatchNicknameResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.PatchPositionResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.VerifyPasswordResponseDto;
import com.fineplay.fineplaybackend.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // 로그인한 유저 정보 가져오기
    @GetMapping("")
    public ResponseEntity<? super GetSignInUserResponseDto> getSignInUser(@AuthenticationPrincipal String email) {
        return userService.getSignInUser(email);
    }

    // 닉네임 수정하기
    @PatchMapping("/nickname")
    public ResponseEntity<? super PatchNicknameResponseDto> patchNickname(
            @RequestBody @Valid PatchNicknameRequestDto requestBody,
            @AuthenticationPrincipal String email
    ) {
            return userService.patchNickname(requestBody, email);
    }

    // 포지션 수정하기
    @PatchMapping("/position")
    public ResponseEntity<? super PatchPositionResponseDto> patchPosition(
            @RequestBody @Valid PatchPositionRequestDto requestBody,
            @AuthenticationPrincipal String email
    ) {
        return userService.patchPosition(requestBody, email);
    }

    // 비밀번호 확인
    @PostMapping("/verify-password")
    public ResponseEntity<? super VerifyPasswordResponseDto> verifyPassword(
            @RequestBody @Valid VerifyPasswordRequestDto requestBody,
            @AuthenticationPrincipal String email
    ) {
        return userService.verifyPassword(requestBody, email);
    }

    // 회원 탈퇴
    @DeleteMapping("")
    public ResponseEntity<? super DeleteUserResponseDto> deleteUser(@AuthenticationPrincipal String email) {
        return userService.deleteUser(email);
    }

    // 유저 스탯 정보 가져오기
    @GetMapping("/stat")
    public ResponseEntity<? super GetUserStatResponseDto> getUserStat(@AuthenticationPrincipal String email) {
        return userService.getUserStat(email);
    }

}
