package com.fineplay.fineplaybackend.teamInfo.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AllMatchRequestDto {
    @NotNull
    private Long teamId;
}
