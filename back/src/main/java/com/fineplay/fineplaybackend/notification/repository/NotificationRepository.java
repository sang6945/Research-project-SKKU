package com.fineplay.fineplaybackend.notification.repository;

import com.fineplay.fineplaybackend.notification.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> { }
