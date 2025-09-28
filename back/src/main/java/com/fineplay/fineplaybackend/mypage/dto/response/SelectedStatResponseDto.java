package com.fineplay.fineplaybackend.mypage.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SelectedStatResponseDto {
    private int status;
    private String stat;
    private String msg;
}
