package com.fineplay.fineplaybackend.user.service.implement;

import com.fineplay.fineplaybackend.auth.dto.response.SignInResponseDto;
import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import com.fineplay.fineplaybackend.provider.JwtProvider;
import com.fineplay.fineplaybackend.user.dto.request.PatchNicknameRequestDto;
import com.fineplay.fineplaybackend.user.dto.request.PatchPositionRequestDto;
import com.fineplay.fineplaybackend.user.dto.request.VerifyPasswordRequestDto;
import com.fineplay.fineplaybackend.user.dto.response.DeleteUserResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.GetSignInUserResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.GetUserStatResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.PatchNicknameResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.PatchPositionResponseDto;
import com.fineplay.fineplaybackend.user.dto.response.VerifyPasswordResponseDto;
import com.fineplay.fineplaybackend.user.service.UserService;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.Response;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImplement implements UserService {

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();


    @Override
    public ResponseEntity<? super GetSignInUserResponseDto> getSignInUser(String email) {
        UserEntity userEntity = null;

        try {
            userEntity = userRepository.findByEmail(email);
            if (userEntity == null) return GetSignInUserResponseDto.notExistUser();

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }

        return GetSignInUserResponseDto.success(userEntity);
    }

    @Override
    public ResponseEntity<? super PatchNicknameResponseDto> patchNickname(PatchNicknameRequestDto dto, String email) {

        try {
            UserEntity userEntity = userRepository.findByEmail(email);
            if (userEntity == null) return PatchNicknameResponseDto.notExistUser();

            String nickname = dto.getNickName();
            boolean existNickname = userRepository.existsByNickName(nickname);
            if (existNickname) return PatchNicknameResponseDto.duplicateNickname();

            userEntity.setNickname(nickname);
            userRepository.save(userEntity);

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }

        return PatchNicknameResponseDto.success();
    }

    @Override
    public ResponseEntity<? super PatchPositionResponseDto> patchPosition(PatchPositionRequestDto dto, String email) {

        try {
            UserEntity userEntity = userRepository.findByEmail(email);
            if (userEntity == null) return PatchPositionResponseDto.notExistUser();

            String position = dto.getPosition();
            userEntity.setPosition(position);
            userRepository.save(userEntity);

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }

        return PatchPositionResponseDto.success();
    }

    @Override
    public ResponseEntity<? super VerifyPasswordResponseDto> verifyPassword(VerifyPasswordRequestDto dto, String email) {
        try {
            UserEntity userEntity = userRepository.findByEmail(email);
            if (userEntity == null) return VerifyPasswordResponseDto.notExistUser();

            String password = dto.getPassword(); // 사용자가 입력한 비밀번호 값
            String encodedPassword = userEntity.getPassword(); // DB에 인코딩되어 저장된 값
            boolean isMatched = passwordEncoder.matches(password, encodedPassword);
            if (!isMatched) return VerifyPasswordResponseDto.decryptFail();

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }

        return VerifyPasswordResponseDto.success();
    }

    @Override
    public ResponseEntity<? super DeleteUserResponseDto> deleteUser(String email) {
        try {
            UserEntity userEntity = userRepository.findByEmail(email);
            if (userEntity == null) return DeleteUserResponseDto.notExistUser();

            userRepository.delete(userEntity);
//            jwtProvider.deleteRefreshToken(email);

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }

        return DeleteUserResponseDto.success();
    }

    @Override
    public ResponseEntity<? super GetUserStatResponseDto> getUserStat(String email) {
        UserEntity userEntity = null;

        try {
            userEntity = userRepository.findByEmail(email);
            if (userEntity == null) return GetUserStatResponseDto.notExistUser();

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }

        return GetUserStatResponseDto.success(userEntity.getUserStat());
    }

}
