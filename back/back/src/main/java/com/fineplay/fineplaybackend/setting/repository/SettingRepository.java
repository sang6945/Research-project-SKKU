package com.fineplay.fineplaybackend.setting.repository;


import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.setting.entity.SettingEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.fineplay.fineplaybackend.setting.dto.response.*;
import com.fineplay.fineplaybackend.setting.dto.request.*;


@Repository
public interface SettingRepository extends JpaRepository<SettingEntity, Long> {
    SettingEntity findByUser(UserEntity user);// ✅ userId 대신 UserEntity 사용


}
