package com.fineplay.fineplaybackend.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class SetNewPasswordRequestDto implements UpdatePasswordRequestDto {

    @NotBlank @Email(message = "이메일 형식이 아닙니다.")
    private String email;

    @NotBlank @Size(min=8, max=20)
    private String newPassword;
}
