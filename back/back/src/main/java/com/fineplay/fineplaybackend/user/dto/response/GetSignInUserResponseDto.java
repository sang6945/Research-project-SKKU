package com.fineplay.fineplaybackend.user.dto.response;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import jakarta.validation.constraints.NotNull;
import java.util.Date;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class GetSignInUserResponseDto extends ResponseDto {

    private String email;
    private String nickName;
    private String realName;
    private String phoneNumber;
    private Date birth;
    private String positon;
    private Boolean boolcert1; // 필수
    private Boolean boolcert2; // 선택
    private Boolean boolcert3; // 선택
    private Boolean boolcert4; // 선택

    private GetSignInUserResponseDto(UserEntity userEntity) {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
        this.email = userEntity.getEmail();
        this.nickName = userEntity.getNickName();
        this.realName = userEntity.getRealName();
        this.phoneNumber = userEntity.getPhoneNumber();
        this.birth = userEntity.getBirth();
        this.positon = userEntity.getPosition();
        this.boolcert1 = userEntity.getBoolcert1();
        this.boolcert2 = userEntity.getBoolcert2();
        this.boolcert3 = userEntity.getBoolcert3();
        this.boolcert4 = userEntity.getBoolcert4();
    }

    // 성공
    public static ResponseEntity<GetSignInUserResponseDto> success(UserEntity userEntity) {
        GetSignInUserResponseDto result = new GetSignInUserResponseDto(userEntity);
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> notExistUser() {
        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }

}
