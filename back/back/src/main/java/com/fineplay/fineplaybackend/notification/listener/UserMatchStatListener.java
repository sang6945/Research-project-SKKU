package com.fineplay.fineplaybackend.notification.listener;// src/main/java/com/fineplay/fineplaybackend/notification/listener/UserMatchStatListener.java
/*package com.fineplay.fineplaybackend.notification.listener;

import com.fineplay.fineplaybackend.config.SpringContext;
import com.fineplay.fineplaybackend.match.entity.UserMatchStatEntity;
import com.fineplay.fineplaybackend.notification.service.NotificationService;
import jakarta.persistence.PostPersist;

public class UserMatchStatListener {

    @PostPersist
    public void onPostPersist(UserMatchStatEntity ums) {
        // SpringContext를 통해 NotificationService를 꺼내와 호출
        NotificationService notifService = SpringContext.getBean(NotificationService.class);
        notifService.notifyMatchParticipants(ums.getMatchId());
    }
}*/
