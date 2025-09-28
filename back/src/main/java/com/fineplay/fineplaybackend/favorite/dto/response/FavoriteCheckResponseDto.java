package com.fineplay.fineplaybackend.favorite.dto.response;

import lombok.Getter;
import org.springframework.http.ResponseEntity;

@Getter
public class FavoriteCheckResponseDto {
    private int status;
    private String message;
    private boolean isFavorite;

    public FavoriteCheckResponseDto(int status, String message, boolean isFavorite) {
        this.status = status;
        this.message = message;
        this.isFavorite = isFavorite;
    }

    public static ResponseEntity<FavoriteCheckResponseDto> success(boolean isFavorite) {
        return ResponseEntity.ok(new FavoriteCheckResponseDto(200, "즐겨찾기 여부 조회 완료", isFavorite));
    }

    public static ResponseEntity<FavoriteCheckResponseDto> badRequest(String msg) {
        return ResponseEntity.badRequest().body(new FavoriteCheckResponseDto(400, msg, false));
    }

    public static ResponseEntity<FavoriteCheckResponseDto> notExistUser() {
        return ResponseEntity.status(404).body(new FavoriteCheckResponseDto(404, "존재하지 않는 유저입니다.", false));
    }

    public static ResponseEntity<FavoriteCheckResponseDto> databaseError() {
        return ResponseEntity.status(500).body(new FavoriteCheckResponseDto(500, "데이터베이스 오류", false));
    }
}
