package com.fineplay.fineplaybackend.favorite.service;

import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import com.fineplay.fineplaybackend.favorite.dto.request.AddFavoriteUserRequestDto;
import com.fineplay.fineplaybackend.favorite.dto.request.DeleteFavoriteUserRequestDto;
import com.fineplay.fineplaybackend.favorite.dto.response.FavoriteCheckResponseDto;
import com.fineplay.fineplaybackend.favorite.dto.response.GetFavoriteUserResponseDto;
import org.springframework.http.ResponseEntity;

public interface FavoriteService {
    ResponseEntity<? super ResponseDto> addFavoriteUser(AddFavoriteUserRequestDto requestDto);
    ResponseEntity<? super ResponseDto> deleteFavoriteUser(DeleteFavoriteUserRequestDto requestDto);
    ResponseEntity<? super FavoriteCheckResponseDto> checkFavoriteUser(Long userId, Long favoriteUserId);
    ResponseEntity<? super GetFavoriteUserResponseDto> getFavoriteUsers(Long userId);
}