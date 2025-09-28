package com.fineplay.fineplaybackend.auth.dto.request;

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
public class FindIdRequestDto {
    @NotBlank
    private String realName;

    @NotBlank @Pattern(regexp="^[0-9]{11,13}$", message = "전화번호 형식이 아닙니다.")
    private String phoneNumber;

    @NotNull @Past
    private Date birth;
}
