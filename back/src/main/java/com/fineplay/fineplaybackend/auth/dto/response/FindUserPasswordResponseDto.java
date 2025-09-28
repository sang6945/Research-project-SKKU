package com.fineplay.fineplaybackend.auth.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

public class FindUserPasswordResponseDto extends ResponseDto {

    private FindUserPasswordResponseDto() {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
    }

    // 성공
    public static ResponseEntity<FindUserPasswordResponseDto> success() {
        FindUserPasswordResponseDto result = new FindUserPasswordResponseDto();
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> notExistUser() {
        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }
}
