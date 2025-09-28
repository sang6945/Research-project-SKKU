package com.fineplay.fineplaybackend.match.entity;

import com.fineplay.fineplaybackend.team.entity.TeamEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import java.util.Date;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="matches")
@Table(name="matches")
public class MatchesEntity {

    @Id
    @GeneratedValue(strategy= GenerationType.IDENTITY)
    private Long matchId;

//    @NotNull
    private Long homeTeamId;

//    @NotNull
    private Long awayTeamId;

    @NotNull
    private Date matchDate;

    @NotNull
    private int homeScore;

    @NotNull
    private int awayScore;

//    @NotNull
    private String location;

//    @NotNull
    private String homeFormation;

//    @NotNull
    private String awayFormation;

    @NotNull
    private Long result;

    @OneToMany(mappedBy = "matches", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ScorerEntity> scorer;

    @OneToMany(mappedBy = "matches", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserMatchStatEntity> userMatchStats;

    @OneToOne(mappedBy = "matches", cascade = CascadeType.ALL, orphanRemoval = true)
    private MatchReportEntity matchReport;

}
