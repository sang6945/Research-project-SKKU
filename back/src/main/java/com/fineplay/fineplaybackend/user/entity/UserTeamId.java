package com.fineplay.fineplaybackend.user.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Embeddable
public class UserTeamId implements Serializable {
    private Long userId;

    private Long teamId;  //둘다 int-> long으로 변경

}
