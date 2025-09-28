package com.fineplay.fineplaybackend.auth.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

public class SetNewPasswordResponseDto extends ResponseDto {

    private SetNewPasswordResponseDto() {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
    }

    // 성공
    public static ResponseEntity<SetNewPasswordResponseDto> success() {
        SetNewPasswordResponseDto result = new SetNewPasswordResponseDto();
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> notExistUser() {
        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }

//    // 비밀번호가 초기화되지 않음
//    public static ResponseEntity<ResponseDto> notInitialized() {
//        ResponseDto result = new ResponseDto(ResponseCode.NOT_INITIALIZED, ResponseMesage.NOT_INITIALIZED);
//        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
//    }
}
