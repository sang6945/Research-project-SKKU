package com.fineplay.fineplaybackend.mypage.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SelectedStatRequestDto {

    @NotNull(message = "UserId cannot be null")  // ✅ UserId 필수
    private Long userId;

    @NotBlank(message = "SelectedStat cannot be blank")  // ✅ selectedStat 필수
    private String selectedStat;
}
