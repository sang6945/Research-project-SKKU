package com.fineplay.fineplaybackend.setting.dto.request;

import lombok.Getter;
import lombok.Setter;
import java.util.Date;

@Getter
@Setter
public class EditProfileRequestDto {
    private String email;
    private String realName;
    private String nickName;
    private String phoneNumber;
    private Date birth; // ISO-8601 포맷 문자열
    private String position;
    private String profileImg;
}

