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
public class SignInRequestDto {
    @NotBlank @Email
    private String email;
    @NotBlank @Size(min=8, max=20)
    private String password;
}
