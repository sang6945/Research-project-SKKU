package com.fineplay.fineplaybackend.setting.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class EditProfileResponseDto {
    private String email;
    private String nickName;


    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date birth;


    private String position;

    private String message;
    private String errorCode;



    // ✅ 메세지 보내는 생성자
    public EditProfileResponseDto(String message, String errorCode) {
        this.message = message;
        this.errorCode = errorCode;
    }

    // ✅ GET 용 생성자
    public EditProfileResponseDto(String email, String nickname, String position, Date birth) {
        this.email = email;
        this.nickName = nickname;
        this.position = position;
        this.birth = birth;

        this.message = "프로필 정보 조회 성공";
        this.errorCode = null;
    }

    // ✅ PATCH 용 메시지 응답
    public static EditProfileResponseDto success() {
        return new EditProfileResponseDto(null, null, null, null, "프로필이 성공적으로 수정되었습니다.", null);
    }

    public static EditProfileResponseDto error(String message, String errorCode) {
        return new EditProfileResponseDto(null, null, null, null, message, errorCode);
    }
}




