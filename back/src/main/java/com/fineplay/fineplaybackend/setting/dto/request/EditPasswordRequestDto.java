package com.fineplay.fineplaybackend.setting.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EditPasswordRequestDto {
    private String email;           // 인증된 사용자 이메일 (서버에서 강제 주입됨)
    private String oldPassword;     // 기존 비밀번호
    private String newPassword;     // 새 비밀번호
}
