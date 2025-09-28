package com.fineplay.fineplaybackend.user.service;

import com.fineplay.fineplaybackend.user.dto.request.PatchNicknameRequestDto;
import com.fineplay.fineplaybackend.user.dto.request.PatchPositionRequestDto;
import com.fineplay.fineplaybackend.user.dto.request.VerifyPasswordRequestDto;
import com.fineplay.fineplaybackend.user.dto.response.DeleteUserResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.GetSignInUserResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.GetUserStatResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.PatchNicknameResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.PatchPositionResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.VerifyPasswordResponseDto;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.RequestBody;

public interface UserService {

    ResponseEntity<? super GetSignInUserResponseDto> getSignInUser(String email);
    ResponseEntity<? super PatchNicknameResponseDto> patchNickname(PatchNicknameRequestDto dto, String email);
    ResponseEntity<? super PatchPositionResponseDto> patchPosition(PatchPositionRequestDto dto, String email);
    ResponseEntity<? super VerifyPasswordResponseDto> verifyPassword(VerifyPasswordRequestDto dto, String email);
    ResponseEntity<? super DeleteUserResponseDto> deleteUser(String email);
    ResponseEntity<? super GetUserStatResponseDto> getUserStat(String email);
}
