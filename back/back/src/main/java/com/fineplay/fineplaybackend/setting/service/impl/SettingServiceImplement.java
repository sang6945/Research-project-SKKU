package com.fineplay.fineplaybackend.setting.service.impl;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
import com.fineplay.fineplaybackend.setting.dto.request.*;
import com.fineplay.fineplaybackend.setting.dto.response.*;
import com.fineplay.fineplaybackend.setting.entity.SettingEntity;
import com.fineplay.fineplaybackend.setting.entity.NoticeEntity;
import com.fineplay.fineplaybackend.setting.repository.*;
import com.fineplay.fineplaybackend.setting.service.intf.SettingService;
import com.fineplay.fineplaybackend.setting.service.intf.NoticeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SettingServiceImplement implements SettingService {

    private final UserRepository userRepository;
    private final SettingRepository settingRepository;
    private final NoticeRepository noticeRepository;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public ResponseEntity<? super AlarmResponseDto> updateMatchAlarm(Long userId, AlarmRequestDto dto) {
        return updateAlarmSetting(userId, "match", dto.getMatchAlarm());
    }

    @Override
    public ResponseEntity<? super AlarmResponseDto> updateCommunityAlarm(Long userId, AlarmRequestDto dto) {
        return updateAlarmSetting(userId, "community", dto.getCommunityAlarm());
    }

    private ResponseEntity<? super AlarmResponseDto> updateAlarmSetting(Long userId, String type, Boolean value) {
        if (value == null) {
            return ResponseEntity.badRequest().body(AlarmResponseDto.error("INVALID_REQUEST"));
        }

        Optional<UserEntity> optionalUser = userRepository.findByUserId(userId);
        if (optionalUser.isEmpty()) {
            return ResponseEntity.badRequest().body(AlarmResponseDto.error("USER_NOT_FOUND"));
        }

        UserEntity user = optionalUser.get();
        SettingEntity setting = settingRepository.findByUser(user);
        if (setting == null) {
            setting = new SettingEntity();
            setting.setUser(user);
            setting.setMatchAlarm(false);
            setting.setCommunityAlarm(false);
        }

        if ("match".equals(type)) {
            setting.setMatchAlarm(value);
        } else if ("community".equals(type)) {
            setting.setCommunityAlarm(value);
        }

        settingRepository.save(setting);

        return ResponseEntity.ok(AlarmResponseDto.success(
                setting.isMatchAlarm(),
                setting.isCommunityAlarm()
        ));
    }

    @Override
    public ResponseEntity<? super EditProfileResponseDto> updateProfile(EditProfileRequestDto request) {
        UserEntity user = userRepository.findByEmail(request.getEmail());
        if (user == null) {
            return ResponseEntity.badRequest().body(new EditProfileResponseDto("해당 이메일의 사용자를 찾을 수 없습니다.", "USER_NOT_FOUND"));
        }

        user.setNickname(request.getNickName());
        user.setBirth(request.getBirth());
        user.setRealName(request.getRealName());
        user.setPosition(request.getPosition());

        userRepository.save(user);
        return ResponseEntity.ok(new EditProfileResponseDto("프로필이 성공적으로 수정되었습니다.", null));
    }

    @Override
    public ResponseEntity<? super EditPasswordResponseDto> updatePassword(EditPasswordRequestDto request) {
        UserEntity user = userRepository.findByEmail(request.getEmail());
        if (user == null) {
            return ResponseEntity.badRequest().body(EditPasswordResponseDto.error("해당 이메일의 사용자를 찾을 수 없습니다.", "USER_NOT_FOUND"));
        }

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            return ResponseEntity.badRequest().body(EditPasswordResponseDto.error("기존 비밀번호가 일치하지 않습니다.", "INCORRECT_PASSWORD"));
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        return ResponseEntity.ok(EditPasswordResponseDto.success());
    }

    @Override
    public ResponseEntity<? super PasswordCheckResponseDto> checkPassword(PasswordCheckRequestDto request) {
        UserEntity user = userRepository.findByEmail(request.getEmail());
        if (user == null) {
            return ResponseEntity.badRequest().body(PasswordCheckResponseDto.error("USER_NOT_FOUND"));
        }

        boolean isCorrect = passwordEncoder.matches(request.getPassword(), user.getPassword());
        return ResponseEntity.ok(new PasswordCheckResponseDto(isCorrect, isCorrect ? null : "INCORRECT_PASSWORD"));
    }

    @Override
    public ResponseEntity<? super EditProfileResponseDto> withdrawUser(String email) {
        UserEntity user = userRepository.findByEmail(email);
        if (user == null) {
            return ResponseEntity.badRequest().body(new EditProfileResponseDto("해당 이메일의 사용자를 찾을 수 없습니다.", "USER_NOT_FOUND"));
        }

        userRepository.delete(user);
        return ResponseEntity.ok(new EditProfileResponseDto("회원 탈퇴 완료", null));
    }

    @Override
    public ResponseEntity<List<NoticeResponseDto>> getNotice() {
        List<NoticeEntity> notices = noticeRepository.findAll();
        List<NoticeResponseDto> response = notices.stream()
                .map(n -> new NoticeResponseDto(n.getId(), n.getTitle(), n.getContent(), n.getCreatedAt().toString(), null))
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }




    @Override
    public ResponseEntity<NoticeResponseDto> getNoticeById(Long id) {
        Optional<NoticeEntity> optionalNotice = noticeRepository.findById(id);
        if (optionalNotice.isPresent()) {
            NoticeEntity notice = optionalNotice.get();
            NoticeResponseDto response = new NoticeResponseDto(
                    notice.getId(),
                    notice.getTitle(),
                    notice.getContent(),
                    notice.getCreatedAt()
            );
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }


    @Override
    public ResponseEntity<? super TermsOfUseResponseDto> getTermsOfUse() {
        return ResponseEntity.ok(new TermsOfUseResponseDto("이용 약관 내용", "이용 약관", null));
    }

    @Override
    public ResponseEntity<? super ReportBugsResponseDto> getReportBugs() {
        return ResponseEntity.ok(new ReportBugsResponseDto("버그 제보 및 문의하기 내용", "버그 제보 및 문의하기", null));
    }
}