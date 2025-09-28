package com.fineplay.fineplaybackend.favorite.service.implement;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import com.fineplay.fineplaybackend.favorite.dto.request.AddFavoriteUserRequestDto;
import com.fineplay.fineplaybackend.favorite.dto.request.DeleteFavoriteUserRequestDto;
import com.fineplay.fineplaybackend.favorite.dto.response.FavoriteCheckResponseDto;
import com.fineplay.fineplaybackend.favorite.dto.response.GetFavoriteUserResponseDto;
import com.fineplay.fineplaybackend.favorite.entity.FavoriteUserEntity;
import com.fineplay.fineplaybackend.favorite.repository.FavoriteUserRepository;
import com.fineplay.fineplaybackend.favorite.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;


@Service
@RequiredArgsConstructor
public class FavoriteServiceImplement implements FavoriteService {

    private final UserRepository userRepository;
    private final FavoriteUserRepository favoriteUserRepository;



    @Override
    public ResponseEntity<? super ResponseDto> addFavoriteUser(AddFavoriteUserRequestDto requestDto) {
        try {
            Long userId = requestDto.getUserId();
            Long targetId = requestDto.getFavoriteUserId();

            if (userId.equals(targetId)) {
                return ResponseEntity.badRequest().body("자기 자신은 즐겨찾기할 수 없습니다.");
            }

            UserEntity user = userRepository.findById(userId).orElse(null);
            UserEntity target = userRepository.findById(targetId).orElse(null);

            if (user == null || target == null) {
                return ResponseEntity.status(404).body("존재하지 않는 유저입니다.");
            }

            boolean exists = favoriteUserRepository.existsByUserIdAndFavoriteUserId(user, target);
            if (exists) {
                return ResponseEntity.status(409).body("이미 즐겨찾기한 유저입니다.");
            }

            FavoriteUserEntity favorite = new FavoriteUserEntity(user, target);
            favoriteUserRepository.save(favorite);

            return ResponseEntity.ok("즐겨찾기 등록 완료");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("데이터베이스 오류");
        }
    }

    @Override
    public ResponseEntity<? super ResponseDto> deleteFavoriteUser(DeleteFavoriteUserRequestDto requestDto) {
        try {
            Long userId = requestDto.getUserId();
            Long favoriteUserId = requestDto.getFavoriteUserId();

            UserEntity user = userRepository.findById(userId).orElse(null);
            UserEntity target = userRepository.findById(favoriteUserId).orElse(null);

            if (user == null || target == null) {
                return ResponseEntity.status(404).body("존재하지 않는 유저입니다.");
            }

            FavoriteUserEntity favorite = favoriteUserRepository
                    .findByUserIdAndFavoriteUserId(user, target)
                    .orElse(null);

            if (favorite == null) {
                return ResponseEntity.status(404).body("즐겨찾기 관계가 존재하지 않습니다.");
            }

            favoriteUserRepository.delete(favorite);
            return ResponseEntity.ok("즐겨찾기 삭제 완료");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("데이터베이스 오류");
        }
    }

    @Override
    public ResponseEntity<FavoriteCheckResponseDto> checkFavoriteUser(Long userId, Long favoriteUserId) {
        try {
            if (userId.equals(favoriteUserId)) {
                return FavoriteCheckResponseDto.badRequest("자기 자신은 확인할 수 없습니다.");
            }

            UserEntity user = userRepository.findById(userId).orElse(null);
            UserEntity target = userRepository.findById(favoriteUserId).orElse(null);

            if (user == null || target == null) {
                return FavoriteCheckResponseDto.notExistUser();
            }

            boolean exists = favoriteUserRepository.existsByUserIdAndFavoriteUserId(user, target);
            return FavoriteCheckResponseDto.success(exists);
        } catch (Exception e) {
            e.printStackTrace();
            return FavoriteCheckResponseDto.databaseError();
        }
    }

    @Override
    public ResponseEntity<GetFavoriteUserResponseDto> getFavoriteUsers(Long userId) {
        try {
            UserEntity user = userRepository.findById(userId).orElse(null);
            if (user == null)
                return GetFavoriteUserResponseDto.notExistUser();

            List<FavoriteUserEntity> favorites = favoriteUserRepository.findByUserId(user);
            return GetFavoriteUserResponseDto.success(favorites);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500)
                    .body(new GetFavoriteUserResponseDto("DB", "데이터베이스 오류", null));
        }
    }
}
