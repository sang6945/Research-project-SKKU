package com.fineplay.fineplaybackend.auth.service.implement;

import com.fineplay.fineplaybackend.auth.dto.request.*;
import com.fineplay.fineplaybackend.auth.dto.response.*;
import com.fineplay.fineplaybackend.auth.service.AuthService;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
//import com.fineplay.fineplaybackend.mypage.entity.UserProfile;
//import com.fineplay.fineplaybackend.mypage.repository.UserProfileRepository;
import com.fineplay.fineplaybackend.provider.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.fineplay.fineplaybackend.user.repository.*;

import com.fineplay.fineplaybackend.auth.dto.request.FindIdRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.FindUserPasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.SetNewPasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.SignInRequestDto;
import com.fineplay.fineplaybackend.auth.dto.request.UpdatePasswordRequestDto;
import com.fineplay.fineplaybackend.auth.dto.response.FindUserPasswordResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.FindIdResponseDto;
//import com.fineplay.fineplaybackend.auth.dto.response.RefreshAccessTokenResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.SetNewPasswordResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.SignInResponseDto;
import com.fineplay.fineplaybackend.auth.dto.response.UpdatePasswordResponseDto;


import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.Duration;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;


@Service
@RequiredArgsConstructor
public class AuthServiceImplement implements AuthService {

    private final UserRepository userRepository;
    private final UserStatRepository userStatRepository;
    private final UserStatImgRepository userStatImgRepository;
    private final JwtProvider jwtProvider;
    private final StringRedisTemplate stringRedisTemplate;
//    private final UserProfileRepository userProfileRepository;

    private PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public ResponseEntity<? super SignUpResponseDto> signUp(SignUpRequestDto dto) {

        try {
            // 이메일 중복 확인
            String email = dto.getEmail();
            boolean existedEmail = userRepository.existsByEmail(email);
            if (existedEmail) return SignUpResponseDto.duplicateEmail();

            // 닉네임 중복 확인
            String nickName = dto.getNickName();
            boolean existedNickName = userRepository.existsByNickName(nickName);
            if (existedNickName) return SignUpResponseDto.duplicateNickname();

            // 핸드폰 번호 중복 확인
            String phoneNumber = dto.getPhoneNumber();
            boolean existedPhoneNumber = userRepository.existsByPhoneNumber(phoneNumber);
            if (existedPhoneNumber) return SignUpResponseDto.duplicatePhoneNumber();

            // 비밀번호 암호화
            String password = dto.getPassword();
            String encodedPassword = passwordEncoder.encode(password);
            dto.setPassword(encodedPassword);

            UserEntity userEntity = new UserEntity(dto);
            userRepository.save(userEntity);


        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }
        return SignUpResponseDto.success();
    }

    @Override
    public ResponseEntity<? super SignInResponseDto> signIn(SignInRequestDto dto, HttpServletResponse response) {

        String accessToken = null;
//        String refreshToken = null;
        Long userId;

        try {
            // 유저 확인
            String email = dto.getEmail();
            UserEntity userEntity = userRepository.findByEmail(email);
            if (userEntity == null) return SignInResponseDto.signInFail(); // 일치하는 유저가 없음

            String password = dto.getPassword(); // 사용자가 입력한 비밀번호 값
            String encodedPassword = userEntity.getPassword(); // DB에 인코딩되어 저장된 값
            boolean isMatched = passwordEncoder.matches(password, encodedPassword);
            if (!isMatched) return SignInResponseDto.signInFail();

            // 토큰 생성
            accessToken = jwtProvider.createAccessToken(email);
//            refreshToken = jwtProvider.createRefreshToken(email);

            // refresh token redis 저장
//            stringRedisTemplate.opsForValue().set("refresh:" + email, refreshToken, Duration.ofDays(1));

            // HttpOnly, Secure 쿠키로 Refresh Token 설정
//            ResponseCookie cookie = ResponseCookie.from("refreshToken", refreshToken)
//                    .httpOnly(true)
//                    .secure(false) // HTTPS일 경우 true
//                    .path("/")
//                    .maxAge(Duration.ofDays(1))
//                    .sameSite("None")
//                    .build();

//            response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());

            userId = userEntity.getUserId();

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }
        return SignInResponseDto.success(accessToken, userId);
    }

    @Override
    public ResponseEntity<? super FindIdResponseDto> findId(FindIdRequestDto dto) {
        try {
            UserEntity userEntity = userRepository.findByRealNameAndPhoneNumberAndBirth(
                    dto.getRealName(),
                    dto.getPhoneNumber(),
                    dto.getBirth()
            );

            if (userEntity == null) return FindIdResponseDto.notExistUser();

            return FindIdResponseDto.success(userEntity.getEmail());

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }
    }

    @Override
    public ResponseEntity<? super FindUserPasswordResponseDto> findPasswordAndReset(FindUserPasswordRequestDto dto) {
        try {
            UserEntity userEntity = userRepository.findByRealNameAndEmailAndPhoneNumberAndBirth(
                    dto.getRealName(),
                    dto.getEmail(),
                    dto.getPhoneNumber(),
                    dto.getBirth()
            );

            if (userEntity == null) return FindUserPasswordResponseDto.notExistUser();

            // 비밀번호 초기화 - null로 설정
            userEntity.setPassword(null);
            userRepository.save(userEntity);

            return FindUserPasswordResponseDto.success();

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }
    }

    @Override
    public ResponseEntity<? super SetNewPasswordResponseDto> setNewPassword(SetNewPasswordRequestDto dto) {
        try {
            UserEntity userEntity = userRepository.findByEmail(dto.getEmail());
            if (userEntity == null) return SetNewPasswordResponseDto.notExistUser();

//            // 비밀번호가 초기화되지 않은 경우 (보안 강화) - 없어도 됨.
//            if (userEntity.getPassword() != null) return SetNewPasswordResponseDto.notInitialized();

            // 새 비밀번호 설정
            userEntity.setPassword(passwordEncoder.encode(dto.getNewPassword()));
            userRepository.save(userEntity);

            return SetNewPasswordResponseDto.success();

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }
    }

    @Override
    public ResponseEntity<? super UpdatePasswordResponseDto> updatePassword(UpdatePasswordRequestDto dto) {
        try {
            if (dto instanceof FindUserPasswordRequestDto request) {
                // 1단계: 사용자 확인
                UserEntity userEntity = userRepository.findByRealNameAndEmailAndPhoneNumberAndBirth(
                        request.getRealName(),
                        request.getEmail(),
                        request.getPhoneNumber(),
                        request.getBirth()
                );

                if (userEntity == null) return UpdatePasswordResponseDto.notExistUser();

                return UpdatePasswordResponseDto.userVerified(); // 유저가 있음


            } else if (dto instanceof SetNewPasswordRequestDto request) {
                // 2단계: 비밀번호 변경
                UserEntity userEntity = userRepository.findByEmail(request.getEmail());
                if (userEntity == null) return UpdatePasswordResponseDto.notExistUser();

                // 새 비밀번호 설정
                userEntity.setPassword(passwordEncoder.encode(request.getNewPassword()));
                userRepository.save(userEntity);

                return UpdatePasswordResponseDto.success();
            }

            return UpdatePasswordResponseDto.invalidRequest(); // 입력 자체에서 문제가 있다면(잘못된 DTO)

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseDto.databaseError();
        }
    }

//    @Override
//    public ResponseEntity<? super RefreshAccessTokenResponseDto> refreshAccessToken(HttpServletRequest request,
//                                                                                    HttpServletResponse response) {
//
//        String refreshToken = null;
//        String email = null;
//
//        try {
//            // 쿠키에서 Refresh Token 추출
//            if (request.getCookies() != null) {
//                for (var cookie : request.getCookies()) {
//                    if (cookie.getName().equals("refreshToken")) {
//                        refreshToken = cookie.getValue();
//                        break;
//                    }
//                }
//            }
//
//            if (refreshToken == null) {
//                return RefreshAccessTokenResponseDto.authenticationError(); // refresh token 없음
//            }
//
//            // Refresh Token 검증
//            email = jwtProvider.validateRefreshJwt(refreshToken);
////            if (email == null) {
////                return RefreshAccessTokenResponseDto.authenticationError(); // 유효하지 않음
////            }
//
//            String savedRefreshToken = stringRedisTemplate.opsForValue().get("refresh:" + email);
//
//            if (savedRefreshToken == null || !savedRefreshToken.equals(refreshToken)) {
//                return RefreshAccessTokenResponseDto.authenticationError(); // 탈취 or 무효 토큰
//            }
//
//            // 사용자 검증
//            UserEntity userEntity = userRepository.findByEmail(email);
//            if (userEntity == null) {
//                return RefreshAccessTokenResponseDto.notExistUser(); // 사용자 없음
//            }
//
//            // 새로운 Access Token 발급
//            String newAccessToken = jwtProvider.createAccessToken(email);
//
//            return RefreshAccessTokenResponseDto.success(newAccessToken, email, userEntity.getUserId());
//
//        } catch (RuntimeException ex) {
//            ex.printStackTrace();
//
//            // 토큰 만료 → 쿠키 삭제
//            deleteRefreshTokenFromCookie(response);
//            return RefreshAccessTokenResponseDto.expiredRefreshToken();
//        }
//        catch (Exception ex) {
//            return ResponseDto.databaseError();
//        }
//    }

    // 쿠키에서 refresh token 삭제
//    private void deleteRefreshTokenFromCookie(HttpServletResponse response) {
//
//        try {
//            ResponseCookie deleteCookie = ResponseCookie.from("refreshToken", "")
//                    .path("/")
//                    .httpOnly(true)
//                    .secure(false) // HTTPS 환경이면 true, 아니면 false
//                    .maxAge(0) // 즉시 만료
//                    .build();
//
//            response.setHeader(HttpHeaders.SET_COOKIE, deleteCookie.toString());
//        } catch(Exception ex) {
//            ex.printStackTrace();
//        }
//    }

    public ResponseEntity<? super CheckEmailDuplicateResponseDto> isEmailDuplicate(CheckEmailDuplicateRequestDto dto) {
        boolean exists = userRepository.existsByEmail(dto.getEmail());
        return ResponseEntity.ok(exists ? CheckEmailDuplicateResponseDto.exists() : CheckEmailDuplicateResponseDto.notExists());
    }


    @Override
    public ResponseEntity<? super CheckNickDuplicateResponseDto> isNickDuplicate(CheckNickDuplicateRequestDto dto) {
        boolean exists = userRepository.existsByNickName(dto.getNickName());
        return ResponseEntity.ok(exists ? CheckNickDuplicateResponseDto.exists() : CheckNickDuplicateResponseDto.notExists());
    }



}
