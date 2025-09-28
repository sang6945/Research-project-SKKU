// 닉네임 검색 요청 DTO
package com.fineplay.fineplaybackend.playerSearch.dto.request;

public class UserSearchRequestDto {
    private String nickname;

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
}

