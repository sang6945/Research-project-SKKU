package com.fineplay.fineplaybackend.auth.dto.response;

import com.fineplay.fineplaybackend.auth.dto.request.SmsVerifyRequestDto;
import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class SmsVerifyResponseDto extends ResponseDto {

    private SmsVerifyResponseDto() {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
    }

    // 성공
    public static ResponseEntity<SmsVerifyResponseDto> success() {
        SmsVerifyResponseDto result = new SmsVerifyResponseDto();
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 인증 번호 인증 실패
    public static ResponseEntity<ResponseDto> wrongCode() {
        ResponseDto result = new ResponseDto(ResponseCode.WRONG_CODE, ResponseMesage.WRONG_CODE);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }
}
