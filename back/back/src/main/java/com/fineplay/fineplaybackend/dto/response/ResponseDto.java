package com.fineplay.fineplaybackend.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
@AllArgsConstructor
public class ResponseDto {
    // 모든 response는 "code", "message"를 가지고 있음
    // 모든 response는 DB error를 가지고 있음

    private String code;
    private String message;

    public static ResponseEntity<ResponseDto> databaseError() {
        ResponseDto responseBody = new ResponseDto(ResponseCode.DATABASE_ERROR, ResponseMesage.DATABASE_ERROR);

        // 500 error
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(responseBody);
    }

    public static ResponseEntity<ResponseDto> validationFailed() {
        ResponseDto responseBody = new ResponseDto(ResponseCode.VALIDATION_FAILED, ResponseMesage.VALIDATION_FAILED);

        // 400 error
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responseBody);
    }
}
