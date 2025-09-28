package com.fineplay.fineplaybackend.team.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class FieldErrorDto {
    private String field;
    private Object rejectedValue;
    private String reason;
}
