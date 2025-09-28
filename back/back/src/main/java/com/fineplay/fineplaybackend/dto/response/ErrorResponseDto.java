package com.fineplay.fineplaybackend.dto.response;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ErrorResponseDto {
    private List<FieldError> fieldErrors;

    @Getter
    @AllArgsConstructor
    public static class FieldError {
        private String field;
        private Object rejectedValue;
        private String reason;
    }
}
