package com.fineplay.fineplaybackend.setting.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TermsOfUseResponseDto {
    private String termstitle;
    private String termsContent;
    private String errCode;

    public static TermsOfUseResponseDto error(String errCode) {
        return new TermsOfUseResponseDto( "이용약관 제목",  "이용약관내용", null);

    }
}
