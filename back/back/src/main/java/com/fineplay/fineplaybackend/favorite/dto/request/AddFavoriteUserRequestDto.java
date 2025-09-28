package com.fineplay.fineplaybackend.favorite.dto.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor

public class AddFavoriteUserRequestDto {
    private Long userId;
    private Long favoriteUserId;
}