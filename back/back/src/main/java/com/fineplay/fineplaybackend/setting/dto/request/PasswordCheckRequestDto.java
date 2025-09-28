package com.fineplay.fineplaybackend.setting.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PasswordCheckRequestDto {
    private String email;
    private String password;
}
