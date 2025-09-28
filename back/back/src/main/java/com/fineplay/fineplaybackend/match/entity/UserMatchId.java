package com.fineplay.fineplaybackend.match.entity;

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
public class UserMatchId implements Serializable {
    private Long userId;
    private Long matchId;
}
