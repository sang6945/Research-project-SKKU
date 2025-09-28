package com.fineplay.fineplaybackend.auth.controller;

import com.fineplay.fineplaybackend.auth.dto.request.CheckNickDuplicateRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.CheckEmailDuplicateRequestDto;
import com.fineplay.fineplaybackend.auth.dto.response.CheckEmailDuplicateResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.CheckNickDuplicateResponseDto;
import com.fineplay.fineplaybackend.auth.dto.request.FindIdRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.FindUserPasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.SetNewPasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.SignInRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.SignUpRequestDto;

import com.fineplay.fineplaybackend.auth.dto.request.UpdatePasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.response.FindUserPasswordResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.FindIdResponseDto;
//import com.fineplay.fineplaybackend.auth.dto.response.RefreshAccessTokenResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.SetNewPasswordResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.SignInResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.SignUpResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.UpdatePasswordResponseDto;
import com.fineplay.fineplaybackend.auth.service.AuthService;
import com.fineplay.fineplaybackend.dto.response.ErrorResponseDto;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;


    @PostMapping("/sign-up")
    public ResponseEntity<? super SignUpResponseDto> signUp(@RequestBody @Valid SignUpRequestDto requestBody, BindingResult bindingResult) {

        if (bindingResult.hasErrors()) {
            List<ErrorResponseDto.FieldError> errors = bindingResult.getFieldErrors().stream()
                    .map(error -> new ErrorResponseDto.FieldError(
                            error.getField(),
                            error.getRejectedValue(),
                            error.getDefaultMessage()))
                    .collect(Collectors.toList());

            ErrorResponseDto errorResponse = new ErrorResponseDto(errors);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }


        // 회원가입 처리
        return authService.signUp(requestBody);
    }

    @PostMapping("/sign-in")
    public ResponseEntity<? super SignInResponseDto> signIn(@RequestBody @Valid SignInRequestDto requestBody, HttpServletResponse response) {
        return authService.signIn(requestBody, response);
    }

    // 아이디 찾기
    @PostMapping("/find-id")
    public ResponseEntity<? super FindIdResponseDto> findId(@RequestBody @Valid FindIdRequestDto requestBody) {
        return authService.findId(requestBody);
    }

    // 비밀번호 찾기 -> 초기화
    @PostMapping("/find-password")
    public ResponseEntity<? super FindUserPasswordResponseDto> findPasswordAndReset(@RequestBody @Valid FindUserPasswordRequestDto requestBody) {
        return authService.findPasswordAndReset(requestBody);
    }

    // 비밀번호 재설정 - 비밀번호가 null 상태일 때만 새 비밀번호 설정 가능
    @PostMapping("/set-new-password")
    public ResponseEntity<? super SetNewPasswordResponseDto> setNewPassword(@RequestBody @Valid SetNewPasswordRequestDto requestBody) {
        return authService.setNewPassword(requestBody);
    }

    // 비밀번호 변경
    @PatchMapping("/password")
    public ResponseEntity<? super UpdatePasswordResponseDto> updatePassword(@RequestBody @Valid UpdatePasswordRequestDto requestBody) {
        return authService.updatePassword(requestBody);
    }

    // refresh token 검증을 통해 access 토큰 재발급
//    @PostMapping("/refresh")
//    public ResponseEntity<? super RefreshAccessTokenResponseDto> refreshAccessToken(HttpServletRequest request, HttpServletResponse response) {
//        return authService.refreshAccessToken(request, response);
//    }


    @PostMapping("/check-email-duplicate")
    public ResponseEntity<? super CheckEmailDuplicateResponseDto> checkEmailDuplicate(
            @RequestBody @Valid CheckEmailDuplicateRequestDto requestBody) {
        return authService.isEmailDuplicate(requestBody);
    }


    // 닉네임 중복 확인 API
    @PostMapping("/check-nick-duplicate")
    public ResponseEntity<? super CheckNickDuplicateResponseDto> checkNickDuplicate(
            @RequestBody @Valid CheckNickDuplicateRequestDto requestBody) {
        return authService.isNickDuplicate(requestBody);
    }

}
