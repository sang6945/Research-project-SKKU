package com.fineplay.fineplaybackend.setting.repository;

import com.fineplay.fineplaybackend.setting.dto.response.ReportBugsResponseDto;
import com.fineplay.fineplaybackend.setting.dto.response.TermsOfUseResponseDto;
import com.fineplay.fineplaybackend.setting.entity.TermsOfUseEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Repository;

@Repository
public interface TermsOfUseRepository extends JpaRepository<TermsOfUseEntity, Long> {


}
