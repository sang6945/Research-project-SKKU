package com.fineplay.fineplaybackend.auth.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class FindIdResponseDto extends ResponseDto {

    private String email;

    private FindIdResponseDto(String email) {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
        this.email = email;
    }

    // 성공
    public static ResponseEntity<FindIdResponseDto> success(String email) {
        FindIdResponseDto result = new FindIdResponseDto(email);
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> notExistUser() {
        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }

}
