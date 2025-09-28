package com.fineplay.fineplaybackend.user.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class PatchNicknameResponseDto extends ResponseDto {
    private PatchNicknameResponseDto() {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
    }

    // 성공
    public static ResponseEntity<PatchNicknameResponseDto> success() {
        PatchNicknameResponseDto result = new PatchNicknameResponseDto();
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> notExistUser() {
        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }

    // 닉네임 중복
    public static ResponseEntity<ResponseDto> duplicateNickname() {
        ResponseDto result = new ResponseDto(ResponseCode.DUPLICATE_NICKNAME, ResponseMesage.DUPLICATE_NICKNAME);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(result);
    }
}
