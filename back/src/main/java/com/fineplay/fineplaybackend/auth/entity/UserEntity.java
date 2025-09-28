package com.fineplay.fineplaybackend.auth.entity;

import com.fineplay.fineplaybackend.auth.dto.request.SignUpRequestDto;
import com.fineplay.fineplaybackend.favorite.entity.FavoriteUserEntity;
import com.fineplay.fineplaybackend.match.entity.UserMatchStatEntity;
import com.fineplay.fineplaybackend.setting.entity.SettingEntity;
import com.fineplay.fineplaybackend.team.entity.TeamEntity;
import com.fineplay.fineplaybackend.team.entity.TeamRequestListEntity;
import com.fineplay.fineplaybackend.team.entity.TeamStatEntity;
import com.fineplay.fineplaybackend.user.entity.UserStatEntity;
import com.fineplay.fineplaybackend.user.entity.UserStatImgEntity;
import com.fineplay.fineplaybackend.user.entity.UserTeamEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Entity(name="user")
@Table(name="`user`")
public class UserEntity {

    @Id @GeneratedValue(strategy=GenerationType.IDENTITY)
    private Long userId;

    @Column(unique = true) @NotNull
    private String email;

//    @NotNull -> 나중에 주석 풀어줘야 해
    private String password;

    @NotNull
    private String realName;

    @Column(unique = true) @NotNull
    private String nickName;

    @NotNull
    private Date birth;

    @Column(unique = true) @NotNull
    private String phoneNumber;

    @NotNull
    private Boolean boolcert1;

    @NotNull
    private Boolean boolcert2;

    @NotNull
    private Boolean boolcert3;

    @NotNull
    private Boolean boolcert4;

    @NotNull
    private String position;

    private String profileImg; // 필수 아님

    // 사용자가 삭제되어도 팀은 삭제되지 않음 왜? 위임해줘야 하니까
    @OneToMany(mappedBy = "teamLeader", cascade = CascadeType.ALL, orphanRemoval = false)
    private List<TeamEntity> teams;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TeamRequestListEntity> userRequests;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserTeamEntity> userTeams;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserMatchStatEntity> userMatchStats;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private UserStatEntity userStat;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private UserStatImgEntity userStatImg;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private SettingEntity userSetting;

//    @OneToMany(mappedBy = "userId", cascade = CascadeType.ALL, orphanRemoval = true)
//    private List<FavoriteUserEntity> favorites;
//
//    @OneToMany(mappedBy = "favoriteUserId", cascade = CascadeType.ALL, orphanRemoval = true)
//    private List<FavoriteUserEntity> favoredBy;

    public UserEntity(SignUpRequestDto dto) {
        this.email = dto.getEmail();
        this.realName = dto.getRealName();
        this.nickName = dto.getNickName();
        this.password = dto.getPassword();
        this.phoneNumber = dto.getPhoneNumber();
        this.birth = dto.getBirth();
        this.position = dto.getPosition();
        this.boolcert1 = dto.getBoolcert1();
        this.boolcert2 = dto.getBoolcert2();
        this.boolcert3 = dto.getBoolcert3();
        this.boolcert4 = dto.getBoolcert4();

    }

    public void setNickname(String nickName) {
        this.nickName = nickName;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setBirth(Date birth) {
        this.birth = birth;
    }

    public void setRealName(String realName) {this.realName = realName;}


}
