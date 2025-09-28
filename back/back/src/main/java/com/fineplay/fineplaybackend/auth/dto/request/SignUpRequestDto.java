package com.fineplay.fineplaybackend.auth.dto.request;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.Date;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class SignUpRequestDto {
    @NotBlank
    private String realName;
    @NotBlank
    private String nickName;
    @NotBlank @Size(min=8, max=20)
    private String password;
    @NotBlank @Email(message = "이메일 형식이 아닙니다.")
    private String email;
    @NotBlank @Pattern(regexp="^[0-9]{11,13}$", message = "전화번호 형식이 아닙니다.")
    private String phoneNumber;
    @NotNull @Past
    private Date birth;
    @NotBlank
    private String position;
    @NotNull @AssertTrue(message = "필수 동의를 선택해야 합니다.")
    private Boolean boolcert1; // 필수
    @NotNull
    private Boolean boolcert2; // 선택
    @NotNull
    private Boolean boolcert3; // 선택
    @NotNull
    private Boolean boolcert4; // 선택
}
