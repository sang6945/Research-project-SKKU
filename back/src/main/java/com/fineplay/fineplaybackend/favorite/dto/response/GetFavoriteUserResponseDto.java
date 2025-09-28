package com.fineplay.fineplaybackend.favorite.dto.response;

import com.fineplay.fineplaybackend.favorite.entity.FavoriteUserEntity;
import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.user.entity.UserStatEntity;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.stream.Collectors;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class GetFavoriteUserResponseDto {

    private String code; // SU, NU 등
    private String message; // 메시지 문자열
    private List<FavoriteUserSummary> favoriteUsers;

    public static ResponseEntity<GetFavoriteUserResponseDto> success(List<FavoriteUserEntity> favoriteEntities) {
        List<FavoriteUserSummary> summaries = favoriteEntities.stream().map(fav -> {
            UserEntity target = fav.getFavoriteUserId();
            UserStatEntity stat = target.getUserStat();
            return new FavoriteUserSummary(
                    target.getUserId(),
                    target.getNickName(),
                    target.getPosition(),
                    stat != null ? stat.getOVR() : 0
            );
        }).collect(Collectors.toList());

        return ResponseEntity.ok(
                new GetFavoriteUserResponseDto("SU", "즐겨찾기 유저 리스트", summaries)
        );
    }

    public static ResponseEntity<GetFavoriteUserResponseDto> notExistUser() {
        return ResponseEntity.status(404).body(
                new GetFavoriteUserResponseDto("NU", "존재하지 않는 유저입니다", null)
        );
    }


    @Getter
    @AllArgsConstructor
    @NoArgsConstructor

    public static class FavoriteUserSummary {
        private Long userId;
        private String nickName;
        private String position;
        private int ovr;
    }
}