package com.fineplay.fineplaybackend.setting.service.intf;

import com.fineplay.fineplaybackend.setting.dto.response.NoticeResponseDto;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface NoticeService {
    ResponseEntity<List<NoticeResponseDto>> getNotice(); // 전체 공지 리스트 조회

    ResponseEntity<NoticeResponseDto> getNoticeById(Long id);// 특정 공지 ID로 조회

}