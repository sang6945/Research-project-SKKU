package com.fineplay.fineplaybackend.user.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class VerifyPasswordResponseDto extends ResponseDto {

    private VerifyPasswordResponseDto() {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
    }

    // 성공
    public static ResponseEntity<VerifyPasswordResponseDto> success() {
        VerifyPasswordResponseDto result = new VerifyPasswordResponseDto();
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> notExistUser() {
        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }

    // 비밀번호 디코딩 실패
    public static ResponseEntity<ResponseDto> decryptFail() {
        ResponseDto result = new ResponseDto(ResponseCode.DECRYPT_FAIL, ResponseMesage.DECRYPT_FAIL);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }
}
