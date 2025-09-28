package com.fineplay.fineplaybackend.notification.dto;

import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class NotificationDto {
    private Long          announcementId;
    private String        type;
    private Long          referenceId;
    private String        title;
    private String        message;
    private Integer       status;
    private LocalDateTime createdAt;

    public NotificationDto(Long announcementId,
                           String type,
                           Long referenceId,
                           String title,
                           String message,
                           Integer status,
                           LocalDateTime createdAt) {
        this.announcementId = announcementId;
        this.type           = type;
        this.referenceId    = referenceId;
        this.title          = title;
        this.message        = message;
        this.status         = status;
        this.createdAt      = createdAt;
    }

    // getters
    public Long getAnnouncementId()     { return announcementId; }
    public String getType()             { return type; }
    public Long getReferenceId()        { return referenceId; }
    public String getTitle()            { return title; }
    public String getMessage()          { return message; }
    public Integer getStatus()          { return status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}