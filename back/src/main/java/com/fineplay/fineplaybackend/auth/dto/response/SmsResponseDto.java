package com.fineplay.fineplaybackend.auth.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class SmsResponseDto extends ResponseDto {

    private SmsResponseDto() {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
    }

    // 성공
    public static ResponseEntity<SmsResponseDto> success() {
        SmsResponseDto result = new SmsResponseDto();
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 이미 가입된 전화번호
    public static ResponseEntity<ResponseDto> existPhoneNumber() {
        ResponseDto result = new ResponseDto(ResponseCode.EXIST_PHONENUMBER, ResponseMesage.EXIST_PHONENUMBER);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }
}
