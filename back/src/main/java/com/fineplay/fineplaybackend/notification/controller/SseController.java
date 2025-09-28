package com.fineplay.fineplaybackend.notification.controller;

import com.fineplay.fineplaybackend.notification.dto.NotificationResponseDto;
import com.fineplay.fineplaybackend.notification.repository.NotificationReceiverRepository;
import com.fineplay.fineplaybackend.notification.repository.NotificationRepository;
import com.fineplay.fineplaybackend.notification.service.NotificationService;
import com.fineplay.fineplaybackend.notification.service.SseEmitterService;
import com.fineplay.fineplaybackend.provider.JwtProvider;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/sse")
@RequiredArgsConstructor
public class SseController {
    private final SseEmitterService              sseService;
    private final NotificationReceiverRepository receiverRepo;
    private final NotificationRepository notificationRepo;
    private final NotificationService notificationService;
    private final JwtProvider jwtProvider;

    /** 1) SSE 구독 **/
    @GetMapping("/subscribe")
    public SseEmitter subscribe(HttpServletRequest request, @RequestParam Long userId) {
        // 토큰 검증
        validateToken(request);  // 토큰 검증 메서드 호출
        return sseService.subscribe(userId);
    }

    /** 2) 알림 목록 조회 **/
    @GetMapping("/notifications")
    public List<NotificationResponseDto> getNotifications(HttpServletRequest request,
                                                          @RequestParam Long userId) {
        validateToken(request);  // 토큰 검증
        return notificationService.getNotifications(userId);  // NotificationResponseDto 반환
    }
    /** 3) 알림 삭제(soft-delete 또는 완전 삭제) **/
    @DeleteMapping("/notifications/{id}")
    public ResponseEntity<Map<String, String>> deleteNotification(HttpServletRequest request,
                                                                  @PathVariable Long id) {
        validateToken(request);
        Long userId = jwtProvider.getUserIdFromRequest(request);

        // 서비스에서 실제 삭제 로직(권한 체크 포함)을 수행하고 메시지를 돌려받는다.
        Map<String, String> result = notificationService.deleteNotification(id, userId);

        String message = result.get("message");
        if ("삭제 권한이 없습니다.".equals(message)) {
            // 권한 없음
            return ResponseEntity.status(403).body(result);
        }
        // 성공(soft-delete 또는 완전 삭제)
        return ResponseEntity.ok(result);
    }

    // ✅ 기존 JwtProvider의 메서드를 활용하여 JWT 유효성만 검증
    private void validateToken(HttpServletRequest request) {
        String token = jwtProvider.getTokenFromRequest(request);
        System.out.println("🔐 토큰: " + token);
        if (token == null) {
            throw new RuntimeException("JWT Token not found in request");
        }
        jwtProvider.validateJwt(token); // ✅ JWT가 유효한지만 확인
    }
}
