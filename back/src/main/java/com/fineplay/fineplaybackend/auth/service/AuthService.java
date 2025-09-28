package com.fineplay.fineplaybackend.auth.service;


import com.fineplay.fineplaybackend.auth.dto.request.FindIdRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.FindUserPasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.SetNewPasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.SignInRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.SignUpRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.UpdatePasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.CheckEmailDuplicateRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.CheckNickDuplicateRequestDto;
import com.fineplay.fineplaybackend.auth.dto.response.FindUserPasswordResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.FindIdResponseDto;
//import com.fineplay.fineplaybackend.auth.dto.response.RefreshAccessTokenResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.SetNewPasswordResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.SignInResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.SignUpResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.UpdatePasswordResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.CheckNickDuplicateResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.CheckEmailDuplicateResponseDto;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.http.ResponseEntity;

public interface AuthService {

    ResponseEntity<? super SignUpResponseDto> signUp(SignUpRequestDto dto);

    ResponseEntity<? super SignInResponseDto> signIn(SignInRequestDto dto, HttpServletResponse response);

    ResponseEntity<? super FindIdResponseDto> findId(FindIdRequestDto dto);

    ResponseEntity<? super FindUserPasswordResponseDto> findPasswordAndReset(FindUserPasswordRequestDto dto);

    ResponseEntity<? super SetNewPasswordResponseDto> setNewPassword(SetNewPasswordRequestDto dto);

    ResponseEntity<? super UpdatePasswordResponseDto> updatePassword(UpdatePasswordRequestDto dto);


    // refresh 토큰을 검증해서 access 토큰 재발급
//    ResponseEntity<? super RefreshAccessTokenResponseDto> refreshAccessToken(HttpServletRequest request, HttpServletResponse response);

    ResponseEntity<? super CheckEmailDuplicateResponseDto> isEmailDuplicate(CheckEmailDuplicateRequestDto dto);

    ResponseEntity<? super CheckNickDuplicateResponseDto> isNickDuplicate(CheckNickDuplicateRequestDto dto);


}
