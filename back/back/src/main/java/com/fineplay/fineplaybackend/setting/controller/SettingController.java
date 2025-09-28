package com.fineplay.fineplaybackend.setting.controller;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.setting.entity.SettingEntity;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
import com.fineplay.fineplaybackend.provider.JwtProvider;
import com.fineplay.fineplaybackend.setting.dto.request.*;
import com.fineplay.fineplaybackend.setting.dto.response.*;
import com.fineplay.fineplaybackend.setting.service.intf.SettingService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;
import com.fineplay.fineplaybackend.setting.dto.request.AlarmRequestDto;
import com.fineplay.fineplaybackend.setting.repository.SettingRepository;
import com.fineplay.fineplaybackend.setting.dto.response.AlarmResponseDto;
import com.fineplay.fineplaybackend.setting.repository.AlarmRepository;
import lombok.RequiredArgsConstructor;
import com.fineplay.fineplaybackend.setting.dto.response.NoticeResponseDto;

@RestController
@RequestMapping("/api/setting")
public class SettingController {

    private final SettingService settingService;
    private final JwtProvider jwtProvider;
    private final UserRepository userRepository;
    private final SettingRepository settingRepository;

    public SettingController(SettingService settingService, JwtProvider jwtProvider, UserRepository userRepository, SettingRepository settingRepository) {
        this.settingService = settingService;
        this.jwtProvider = jwtProvider;
        this.userRepository = userRepository;
        this.settingRepository = settingRepository;
    }

    public SettingEntity getOrCreateSetting(UserEntity user) {
        SettingEntity setting = settingRepository.findByUser(user);
        if (setting == null) {
            setting = new SettingEntity();
            setting.setUser(user);
            setting.setMatchAlarm(false);
            setting.setCommunityAlarm(false);
            settingRepository.save(setting);
        }
        return setting;
    }

    @GetMapping("")
    public ResponseEntity<?> getAlarmStatus(HttpServletRequest request) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body("UNAUTHORIZED: 토큰이 유효하지 않습니다.");
        }
        SettingEntity setting = getOrCreateSetting(user);
        if (setting == null) {
            return ResponseEntity.status(404).body("설정 정보가 존재하지 않습니다.");
        }
        SettingStatusDto responseDto = new SettingStatusDto(
                setting.isMatchAlarm(),
                setting.isCommunityAlarm()
        );
        return ResponseEntity.ok(responseDto);
    }

    @GetMapping("/AccountInfo")
    public ResponseEntity<?> getUserProfile(HttpServletRequest request) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(EditProfileResponseDto.error("UNAUTHORIZED: 유효하지 않은 토큰입니다.", "UNAUTHORIZED"));
        }
        EditProfileResponseDto response = new EditProfileResponseDto(
                user.getEmail(),
                user.getNickName(),
                user.getPosition(),
                user.getBirth()
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/AccountInfo/EditProfile")
    public ResponseEntity<?> getEditProfile(HttpServletRequest request) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(EditProfileResponseDto.error("UNAUTHORIZED: 유효하지 않은 토큰입니다.", "UNAUTHORIZED"));
        }
        EditProfileResponseDto response = new EditProfileResponseDto(
                user.getEmail(),
                user.getNickName(),
                user.getPosition(),
                user.getBirth()
        );
        return ResponseEntity.ok(response);
    }

    @PatchMapping("/AccountInfo/EditProfile")
    public ResponseEntity<? super EditProfileResponseDto> editProfile(HttpServletRequest request, @RequestBody EditProfileRequestDto editRequest) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(EditProfileResponseDto.error("인증 실패: 유효하지 않은 토큰입니다.", "UNAUTHORIZED"));
        }
        editRequest.setEmail(user.getEmail());
        return settingService.updateProfile(editRequest);
    }

    @PatchMapping("/AccountInfo/EditPassword")
    public ResponseEntity<? super EditPasswordResponseDto> editPassword(HttpServletRequest request, @RequestBody EditPasswordRequestDto passwordRequest) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(EditPasswordResponseDto.error("인증 실패: 유효하지 않은 토큰입니다.", "UNAUTHORIZED"));
        }
        passwordRequest.setEmail(user.getEmail());
        return settingService.updatePassword(passwordRequest);
    }

    @PostMapping("/AccountInfo/withdraw/CheckPassword")
    public ResponseEntity<? super PasswordCheckResponseDto> checkPassword(HttpServletRequest request, @RequestBody PasswordCheckRequestDto passwordRequest) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(PasswordCheckResponseDto.error("인증 실패: 유효하지 않은 토큰입니다."));
        }
        passwordRequest.setEmail(user.getEmail());
        return settingService.checkPassword(passwordRequest);
    }

    @DeleteMapping("/AccountInfo/withdraw/WithdrawService")
    public ResponseEntity<? super EditProfileResponseDto> withdrawUser(HttpServletRequest request) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(EditProfileResponseDto.error("인증 실패: 유효하지 않은 토큰입니다.", "UNAUTHORIZED"));
        }
        return settingService.withdrawUser(user.getEmail());
    }

    @PatchMapping("/MatchAlarm")
    public ResponseEntity<?> updateMatchAlarm(HttpServletRequest request, @RequestBody AlarmRequestDto dto) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(AlarmResponseDto.error("UNAUTHORIZED"));
        }
        return settingService.updateMatchAlarm(user.getUserId(), dto);
    }

    @PatchMapping("/CommunityAlarm")
    public ResponseEntity<?> updateCommunityAlarm(HttpServletRequest request, @RequestBody AlarmRequestDto dto) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(AlarmResponseDto.error("UNAUTHORIZED"));
        }
        return settingService.updateCommunityAlarm(user.getUserId(), dto);
    }

    @PatchMapping("/UpdateAlarm")
    public ResponseEntity<?> updateAlarmSetting(HttpServletRequest request, @RequestBody AlarmUpdateRequestDto dto) {
        UserEntity user = validateTokenAndGetUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body("UNAUTHORIZED: 유효하지 않은 토큰입니다.");
        }
        SettingEntity setting = getOrCreateSetting(user);
        if ("matchAlarm".equals(dto.getType())) {
            setting.setMatchAlarm(dto.getValue());
        } else if ("communityAlarm".equals(dto.getType())) {
            setting.setCommunityAlarm(dto.getValue());
        } else {
            return ResponseEntity.badRequest().body("Invalid alarm type.");
        }
        settingRepository.save(setting);
        return ResponseEntity.ok("알림 설정이 업데이트되었습니다.");
    }

    @GetMapping("/Notice")
    public ResponseEntity<List<NoticeResponseDto>> getNotice() {
        return settingService.getNotice();
    }

    @GetMapping("/Notice/{id}")
    public ResponseEntity<?> getNoticeById(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(settingService.getNoticeById(id));
        } catch (Exception e) {
            return ResponseEntity.status(404).body("공지사항을 찾을 수 없습니다.");
        }
    }

    @GetMapping("/TermsOfUse")
    public ResponseEntity<? super TermsOfUseResponseDto> getTermsOfUse() {
        return settingService.getTermsOfUse();
    }

    @GetMapping("/ReportBugs")
    public ResponseEntity<? super ReportBugsResponseDto> getReportBugs() {
        return settingService.getReportBugs();
    }

    private UserEntity validateTokenAndGetUser(HttpServletRequest request) {
        String token = jwtProvider.getTokenFromRequest(request);
        if (token == null) return null;
        String email = jwtProvider.validateJwt(token);
        if (email == null) return null;
        return userRepository.findByEmail(email);
    }
}