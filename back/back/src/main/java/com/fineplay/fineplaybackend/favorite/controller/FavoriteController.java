package com.fineplay.fineplaybackend.favorite.controller;

import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import com.fineplay.fineplaybackend.favorite.dto.request.AddFavoriteUserRequestDto;
import com.fineplay.fineplaybackend.favorite.dto.request.DeleteFavoriteUserRequestDto;
import com.fineplay.fineplaybackend.favorite.dto.response.FavoriteCheckResponseDto;
import com.fineplay.fineplaybackend.favorite.dto.response.GetFavoriteUserResponseDto;
import com.fineplay.fineplaybackend.favorite.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/favorite")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;

    @PostMapping("/user/add")
    public ResponseEntity<? super ResponseDto> addFavoriteUser(@RequestBody AddFavoriteUserRequestDto requestDto) {
        return favoriteService.addFavoriteUser(requestDto);
    }

    @DeleteMapping("/user/delete")
    public ResponseEntity<? super ResponseDto> deleteFavoriteUser(@RequestBody DeleteFavoriteUserRequestDto requestDto) {
        return favoriteService.deleteFavoriteUser(requestDto);
    }

    @GetMapping("/user/check")
    public ResponseEntity<? super FavoriteCheckResponseDto> checkFavoriteUser(@RequestParam Long userId, @RequestParam Long favoriteUserId) {
        return favoriteService.checkFavoriteUser(userId, favoriteUserId);
    }

    @GetMapping("/user/list")
    public ResponseEntity<? super GetFavoriteUserResponseDto> getFavoriteUserList(@RequestParam Long userId) {
        return favoriteService.getFavoriteUsers(userId);
    }
}
