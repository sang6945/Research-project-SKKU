package com.fineplay.fineplaybackend.team.entity;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.user.entity.UserTeamEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.List;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Entity(name = "team")
@Table(name = "team")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TeamEntity {

    @Id @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long teamId;

    @NotNull @Column(unique = true)
    private String teamName;

    @ManyToOne
    @JoinColumn(name = "teamLeader")
    @OnDelete(action = OnDeleteAction.SET_NULL) // 리더가 삭제되면 null로 설정
    private UserEntity teamLeader;

    private String region;
    private String teamType;
    private String teamImg;
    private Integer memberNum;
    private String OVRDist;

    @Column(nullable = false)
    private Integer totalWin = 0;

    @Column(nullable = false)
    private Integer totalDraw = 0;

    @Column(nullable = false)
    private Integer totalLose = 0;


    @OneToMany(mappedBy = "team", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TeamRequestListEntity> teamRequests;

    @OneToOne(mappedBy = "team", cascade = CascadeType.ALL, orphanRemoval = true)
    private TeamStatEntity teamStat;

    @OneToMany(mappedBy = "team", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserTeamEntity> userTeams;


}
