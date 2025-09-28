package com.fineplay.fineplaybackend.auth.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class SignUpResponseDto extends ResponseDto {
    private SignUpResponseDto() {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
    }

    // 성공
    public static ResponseEntity<SignUpResponseDto> success() {
        SignUpResponseDto result = new SignUpResponseDto();
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 이메일 중복
    public static ResponseEntity<ResponseDto> duplicateEmail() {
        ResponseDto result = new ResponseDto(ResponseCode.DUPLICATE_EMAIL, ResponseMesage.DUPLICATE_EMAIL);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }

    // 닉네임 중복
    public static ResponseEntity<ResponseDto> duplicateNickname() {
        ResponseDto result = new ResponseDto(ResponseCode.DUPLICATE_NICKNAME, ResponseMesage.DUPLICATE_NICKNAME);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }

    // 핸드폰 번호 중복
    public static ResponseEntity<ResponseDto> duplicatePhoneNumber() {
        ResponseDto result = new ResponseDto(ResponseCode.DUPLICATE_PHONE_NUMBER, ResponseMesage.DUPLICATE_PHONE_NUMBER);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }
}
