//package com.fineplay.fineplaybackend.auth.dto.response;
//
//import com.fineplay.fineplaybackend.common.ResponseCode;
//import com.fineplay.fineplaybackend.common.ResponseMesage;
//import com.fineplay.fineplaybackend.dto.response.ResponseDto;
//import jakarta.servlet.http.HttpServletResponse;
//import lombok.Getter;
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//
//@Getter
//public class RefreshAccessTokenResponseDto extends ResponseDto {
//    private Long userId;
//    private String email;
//    private String token;
//
//    private RefreshAccessTokenResponseDto(String token, String email, Long userId) {
//        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
//        this.userId = userId;
//        this.email = email;
//        this.token = token;
//    }
//
//    // 성공
//    public static ResponseEntity<RefreshAccessTokenResponseDto> success(String accessToken, String email, Long userId) {
//        RefreshAccessTokenResponseDto result = new RefreshAccessTokenResponseDto(accessToken, email, userId);
//        return ResponseEntity.status(HttpStatus.OK).body(result);
//    }
//
//    // 유저 정보 없음
//    public static ResponseEntity<ResponseDto> notExistUser() {
//        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
//        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
//    }
//
//    // 토큰 이상
//    public static ResponseEntity<ResponseDto> authenticationError() {
//        ResponseDto result = new ResponseDto(ResponseCode.AUTHORIZATION_FAIL, ResponseMesage.AUTHORIZATION_FAIL);
//        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
//    }
//
//    // refresh 토큰 만료
//    public static ResponseEntity<ResponseDto> expiredRefreshToken() {
//        ResponseDto result = new ResponseDto(ResponseCode.EXPIRED_REFRESHTOKEN, ResponseMesage.EXPIRED_REFRESHTOKEN);
//        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
//    }
//}
