package com.fineplay.fineplaybackend.provider;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import jakarta.servlet.http.HttpServletRequest;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;

// JWT 발급을 위한 provider
@Component
public class JwtProvider {

    @Value("${secret-access-key}")
    private String accessKey;

//    @Value("${secret-refresh-key}")
//    private String refreshKey;

    private final UserRepository userRepository;

    // UserRepository를 주입받기 위해 생성자 추가
    public JwtProvider(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // AccessToken 생성하는 메서드
    public String createAccessToken(String email) {
        Key key = Keys.hmacShaKeyFor(accessKey.getBytes(StandardCharsets.UTF_8));
        Date expiredTime = Date.from(Instant.now().plus(1, ChronoUnit.HOURS)); // 1시간
        return Jwts.builder()
                .signWith(key, SignatureAlgorithm.HS256)
                .setSubject(email) // email이 주체
                .setIssuedAt(new Date()) // 생성 시간
                .setExpiration(expiredTime) // 만료 시간
                .compact();
    }

    // RefreshToken 생성하는 메서드
//    public String createRefreshToken(String email) {
//        Key key = Keys.hmacShaKeyFor(refreshKey.getBytes(StandardCharsets.UTF_8));
//        Date expiredTime = Date.from(Instant.now().plus(1, ChronoUnit.DAYS)); // 하루
//        return Jwts.builder()
//                .signWith(key, SignatureAlgorithm.HS256)
//                .setSubject(email) // email이 주체
//                .setIssuedAt(new Date()) // 생성 시간
//                .setExpiration(expiredTime) // 만료 시간
//                .compact();
//    }

    // access token 검증 메서드 - 이메일을 가져올 수 있음
    public String validateJwt(String token) {
        try {
            Key key = Keys.hmacShaKeyFor(accessKey.getBytes(StandardCharsets.UTF_8)); // 동적으로 생성
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key) // token을 파싱
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            return claims.getSubject(); // token을 파싱해서 토큰 생성할 때 넣은 email을 가져옴

        } catch (io.jsonwebtoken.ExpiredJwtException ex) {
            throw new RuntimeException("JWT has expired", ex);
        } catch (io.jsonwebtoken.SignatureException ex) {
            throw new RuntimeException("Invalid JWT signature", ex);
        } catch (Exception ex) {
            throw new RuntimeException("Invalid JWT token", ex);
        }
    }

    // refresh token 검증 메서드
//    public String validateRefreshJwt(String token) {
//        try {
//            Key key = Keys.hmacShaKeyFor(refreshKey.getBytes(StandardCharsets.UTF_8));
//            Claims claims = Jwts.parserBuilder()
//                    .setSigningKey(key)
//                    .build()
//                    .parseClaimsJws(token)
//                    .getBody();
//            return claims.getSubject();
//        } catch (Exception ex) {
//            throw new RuntimeException("Invalid JWT token", ex);
//        }
//    }


    public String getTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");

        if (bearerToken == null) {
//            System.out.println("🚨 [JWT ERROR] Authorization 헤더가 없습니다.");
            return null;
        }

        if (!bearerToken.startsWith("Bearer ")) {
//            System.out.println("🚨 [JWT ERROR] Authorization 헤더 형식이 잘못되었습니다: " + bearerToken);
            return null;
        }

        String token = bearerToken.substring(7);
//        System.out.println("✅ [JWT SUCCESS] 추출된 토큰: " + token);
        return token;
    }

    // ✅ JWT에서 userId 반환하는 메서드 추가
    public Long getUserIdFromJwt(String token) {
        String email = validateJwt(token); // 이메일 추출
        UserEntity user = userRepository.findByEmail(email);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        return user.getUserId(); // userId 반환
    }

    // ✅ HTTP 요청에서 userId 추출
    public Long getUserIdFromRequest(HttpServletRequest request) {
        String token = getTokenFromRequest(request);
        if (token == null) {
//            System.out.println("🚨 [JWT ERROR] 토큰을 찾을 수 없습니다.");
            return null;
        }

        String email = validateJwt(token);
        if (email == null) {
//            System.out.println("🚨 [JWT ERROR] JWT 검증 실패. 이메일 없음.");
            return null;
        }

        UserEntity user = userRepository.findByEmail(email);
        if (user == null) {
//            System.out.println("🚨 [JWT ERROR] 이메일에 해당하는 사용자 없음: " + email);
            return null;
        }

//        System.out.println("✅ [JWT SUCCESS] userId 반환: " + user.getUserId());
        return user.getUserId();
    }
}
