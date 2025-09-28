package com.fineplay.fineplaybackend.playerSearch.dto.response;

public class UserSearchResponseDto {
    private Long userId;
    private String nickName;

    public UserSearchResponseDto(Long userId, String nickName) {
        this.userId = userId;
        this.nickName = nickName;
    }

    // Getter
    public Long getUserId() {
        return userId;
    }

    public String getNickName() {
        return nickName;
    }
}
