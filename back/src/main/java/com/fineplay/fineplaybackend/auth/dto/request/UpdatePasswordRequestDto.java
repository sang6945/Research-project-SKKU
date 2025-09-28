package com.fineplay.fineplaybackend.auth.dto.request;


import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

@JsonTypeInfo(
        use = JsonTypeInfo.Id.NAME,
        include = JsonTypeInfo.As.PROPERTY,
        property = "type" // JSON에 이 필드를 포함시켜야 함
)
@JsonSubTypes({
        @JsonSubTypes.Type(value = FindUserPasswordRequestDto.class, name = "findUser"),
        @JsonSubTypes.Type(value = SetNewPasswordRequestDto.class, name = "setNewPassword")
})
public interface UpdatePasswordRequestDto {
}
