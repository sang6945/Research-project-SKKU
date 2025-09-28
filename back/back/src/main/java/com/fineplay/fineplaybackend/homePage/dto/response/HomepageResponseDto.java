package com.fineplay.fineplaybackend.homePage.dto.response;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Data
public class HomepageResponseDto {
    private int status;

    // 사용자 정보
    private String userName;
    private String position;
    private String ovr;
    private String selectedStat;
    private String profileImg;

    // Special Stats
    private int CRO;
    private int HED;
    private int FST;
    private int ACT;
    private int OFF;
    private int TEC;
    private int COP;

    // Common Stats
    private int PAC;
    private int PAS;
    private int SPD;

    // Position Stats: FW
    private int SHO;
    private int DRV;

    // Position Stats: MF
    private int DEC;
    private int DRI;

    // Position Stats: DF
    private int TAC;
    private int BLD;


    // my team
    private String currentTeam;
    private String teamImg;
    //private String win;
    //private String draw;
    //private String lose; //테이블 수정필요!!
    private String fw;
    private String mf;
    private String df;
    private boolean hasUnreadNotification;

    // favorite users
    //private List<FavoriteUser> favoriteUser; //테이블 추가후 해당 기능 넣어야함.

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FavoriteUser {
        private Long userId;
        private String nickName;
        private String profileImg;
    }
}
