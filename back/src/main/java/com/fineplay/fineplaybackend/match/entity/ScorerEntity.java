package com.fineplay.fineplaybackend.match.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="scorer")
@Table(name="scorer")
public class ScorerEntity {
    @Id
    @GeneratedValue(strategy= GenerationType.IDENTITY)
    private Long scorerTableId;

    @ManyToOne
    @JoinColumn(name = "matchId")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private MatchesEntity matches;

    private String userName;

    private String time;

    private Boolean isHome;
}
