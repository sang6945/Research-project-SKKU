package com.fineplay.fineplaybackend.notification.service;

import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class SseEmitterService {
    private final Map<Long, SseEmitter> emitters = new ConcurrentHashMap<>();

    public SseEmitter subscribe(Long userId) {
        SseEmitter emitter = new SseEmitter(Long.MAX_VALUE);
        emitter.onTimeout(()   -> emitters.remove(userId));
        emitter.onCompletion(()-> emitters.remove(userId));
        emitters.put(userId, emitter);
        return emitter;
    }

    public void sendNotification(Long userId, Object data) {
        SseEmitter emitter = emitters.get(userId);
        if (emitter != null) {
            try {
                emitter.send(SseEmitter.event().name("notification").data(data));
            } catch (IOException e) {
                emitters.remove(userId);
            }
        }
    }

    public void sendToAll(Object data) {
        emitters.forEach((uid, emitter) -> {
            try {
                emitter.send(SseEmitter.event().name("notification").data(data));
            } catch (IOException e) {
                emitters.remove(uid);
            }
        });
    }
}
