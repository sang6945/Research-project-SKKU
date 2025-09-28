package com.fineplay.fineplaybackend.match.service;

import com.fineplay.fineplaybackend.match.dto.response.RecentMatchRecordResponseDto;

public interface MatchService {
    RecentMatchRecordResponseDto getRecentMatchRecord(Long teamId);
}
