package com.fineplay.fineplaybackend.notification.repository;

import com.fineplay.fineplaybackend.notification.entity.NotificationReceiver;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationReceiverRepository extends JpaRepository<NotificationReceiver, Long> {
    List<NotificationReceiver> findByUserId(Long userId);

    boolean existsByUserIdAndIsReadFalse(Long userId);
}
