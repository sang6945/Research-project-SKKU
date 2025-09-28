package com.fineplay.fineplaybackend.setting.repository;

import com.fineplay.fineplaybackend.setting.dto.response.ReportBugsResponseDto;
import org.springframework.http.ResponseEntity;

public interface ReportRepository {
    ResponseEntity<? super ReportBugsResponseDto> getReportBugs();
}
