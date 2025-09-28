package com.fineplay.fineplaybackend.auth.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import jakarta.servlet.http.HttpServletResponse;
import java.time.Duration;
import lombok.Getter;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;

@Getter
public class SignInResponseDto extends ResponseDto {

    private Long userId;
    private String token;
    private int expirationTime;

    private SignInResponseDto(String token, Long userId)  {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
        this.userId = userId;
        this.token = token;
        this.expirationTime = 3600; // 1 시간
    }

    // 성공
    public static ResponseEntity<SignInResponseDto> success(String accessToken, Long userId) {
//        SignInResponseDto result = new SignInResponseDto(accessToken, userId);
//        return ResponseEntity.status(HttpStatus.OK).header("X-Refresh-Token", refreshToken).body(result);

        // Access Token은 JSON body로
        SignInResponseDto result = new SignInResponseDto(accessToken, userId);
//        return ResponseEntity.status(HttpStatus.OK).header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken).body(result);
        return ResponseEntity.status(HttpStatus.OK).body(result);

    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> signInFail() {
        ResponseDto result = new ResponseDto(ResponseCode.SIGN_IN_FAIL, ResponseMesage.SIGN_IN_FAIL);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }
}
