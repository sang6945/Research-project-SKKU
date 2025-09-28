package com.fineplay.fineplaybackend.auth.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class UpdatePasswordResponseDto extends ResponseDto {

    private UpdatePasswordResponseDto() {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
    }

    // 성공
    public static ResponseEntity<UpdatePasswordResponseDto> success() {
        UpdatePasswordResponseDto result = new UpdatePasswordResponseDto();
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> notExistUser() {
        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(result);
    }

    // 유저 찾기 성공
    public static ResponseEntity<ResponseDto> userVerified() {
        ResponseDto result = new ResponseDto(ResponseCode.SUCCESS_FIND_USER, ResponseMesage.SUCCESS_FIND_USER);
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // DTO가 잘못됨 - 400
    public static ResponseEntity<ResponseDto> invalidRequest() {
        ResponseDto result = new ResponseDto(ResponseCode.WRONG_INPUT, ResponseMesage.WRONG_INPUT);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }
}
