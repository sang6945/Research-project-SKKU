package com.fineplay.fineplaybackend.mypage.service.impl;

import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.mypage.dto.request.PageMoveRequestDto;
import com.fineplay.fineplaybackend.mypage.dto.request.SelectedStatRequestDto;
import com.fineplay.fineplaybackend.mypage.dto.response.MypageProfileResponseDto;
import com.fineplay.fineplaybackend.mypage.dto.response.PageMoveResponseDto;
import com.fineplay.fineplaybackend.mypage.dto.response.SelectedStatResponseDto;
import com.fineplay.fineplaybackend.notification.repository.NotificationReceiverRepository;
import com.fineplay.fineplaybackend.team.repository.*;
import com.fineplay.fineplaybackend.user.repository.*;
import com.fineplay.fineplaybackend.auth.repository.*;
import com.fineplay.fineplaybackend.mypage.service.MypageService;
import com.fineplay.fineplaybackend.team.entity.TeamEntity;
import com.fineplay.fineplaybackend.user.entity.UserStatEntity;
import com.fineplay.fineplaybackend.user.entity.UserStatImgEntity;
import com.fineplay.fineplaybackend.user.entity.UserTeamEntity;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MypageServiceImpl implements MypageService {

    private final UserRepository userRepository;
    private final UserStatRepository userStatRepository;
    private final UserStatImgRepository userStatImgRepository;
    private final UserTeamRepository userTeamRepository;
    private final TeamRepository teamRepository;
    private final NotificationReceiverRepository receiverRepo;

    // ✅ 1. 마이페이지 프로필 조회
    @Override
    public MypageProfileResponseDto getMypageProfile(Long userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID"));

        UserStatEntity stat = userStatRepository.findByUserId(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID_FOR_USER_STAT"));

        UserStatImgEntity statImg = userStatImgRepository.findByUserId(userId).orElse(null); // ✔ 없으면 null

        // --- 1) userTeams 불러오기 ---
        List<UserTeamEntity> userTeams = userTeamRepository.findAllByUserId(userId);

        // --- 2) 최대 3개, 부족하면 null 채우기 ---
        List<MypageProfileResponseDto.MyTeamList> teams = new ArrayList<>();
        for (int i = 0; i < 3; i++) {
            if (i < userTeams.size()) {
                TeamEntity t = userTeams.get(i).getTeam();
                teams.add(new MypageProfileResponseDto.MyTeamList(
                        t.getTeamId(),
                        t.getTeamName()
                ));
            } else {
                // 팀이 부족한 경우에도 DTO 객체를 생성하되, 필드는 모두 null
                teams.add(new MypageProfileResponseDto.MyTeamList(
                        null,
                        null
                ));
            }
        }

        // 3) OVR 퍼센타일 계산: 전체 중에서 이 OVR보다 높은(또는 같은) 사람이 몇 %인가
        int userOvr = stat.getOVR();
        long totalCount = userStatRepository.count();  // JpaRepository.count()
        long higherCount = userStatRepository.countByOVRGreaterThan(userOvr);
        // 상위 퍼센트 = ceil( (higherCount / totalCount) * 100 )
        int ovrPercent = totalCount > 0
                ? (int)Math.ceil(higherCount * 100.0 / totalCount)
                : 0;


        boolean hasUnread = receiverRepo.existsByUserIdAndIsReadFalse(userId);

        return MypageProfileResponseDto.builder()
                .status(200)
                .userName(user.getNickName())
                .position(user.getPosition())
                .ProfileImg(user.getProfileImg())
                .ovr(String.valueOf(stat.getOVR()))
                .ovrPercent(String.valueOf(ovrPercent))
                .selectedStat(stat.getSelectedStat())

                // Special Stats
                .CRO(stat.getCRO())
                .HED(stat.getHED())
                .FST(stat.getFST())
                .ACT(stat.getACT())
                .OFF(stat.getOFF())
                .TEC(stat.getTEC())
                .COP(stat.getCOP())

                // Common Stats
                .PAC(stat.getPAC())
                .PAS(stat.getPAS())
                .SPD(stat.getSPD())

                // Position Stats: FW
                .SHO(stat.getSHO())
                .DRV(stat.getDRV())

                // Position Stats: MF
                .DEC(stat.getDEC())
                .DRI(stat.getDRI())

                // Position Stats: DF
                .TAC(stat.getTAC())
                .BLD(stat.getBLD())

                // Stat Images (null-safe)
                .CROImg(statImg != null ? statImg.getCROImg() : null)
                .HEDImg(statImg != null ? statImg.getHEDImg() : null)
                .FSTImg(statImg != null ? statImg.getFSTImg() : null)
                .ACTImg(statImg != null ? statImg.getACTImg() : null)
                .OFFImg(statImg != null ? statImg.getOFFImg() : null)
                .TECImg(statImg != null ? statImg.getTECImg() : null)
                .COPImg(statImg != null ? statImg.getCOPImg() : null)
                .teams(teams)
                .hasUnreadNotification(hasUnread)
                .build();
    }

    // ✅ 2. 선택된 스탯 저장
    @Override
    @Transactional
    public SelectedStatResponseDto updateSelectedStat(Long tokenUserId, SelectedStatRequestDto requestDto) {
        Long userId = requestDto.getUserId();

        if (!tokenUserId.equals(userId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID_MISMATCH");
        }

        UserStatEntity stat = userStatRepository.findByUserId(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID"));

        String selectedStat = requestDto.getSelectedStat().toUpperCase();
        Set<String> validStats = Set.of("CRO", "HED", "FST", "ACT", "OFF", "TEC", "COP");

        if (!validStats.contains(selectedStat)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_SELECTED_STAT");
        }

        stat.setSelectedStat(selectedStat);
        userStatRepository.save(stat);

        return SelectedStatResponseDto.builder()
                .status(200)
                .stat(selectedStat)
                .msg("stat update : " + selectedStat)
                .build();
    }

    // ✅ 3. 특정 스탯 이미지 조회 (페이지 이동용)
    @Override
    public PageMoveResponseDto movePage(String statName, PageMoveRequestDto requestDto) {
        Long userId = requestDto.getUserId();

        UserStatImgEntity statImg = userStatImgRepository.findByUserId(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_USER_ID"));

        Map<String, String> statImageMap = new HashMap<>();
        statImageMap.put("PAC", statImg.getPACImg());
        statImageMap.put("SPD", statImg.getSPDImg());
        statImageMap.put("PAS", statImg.getPASImg());
        statImageMap.put("SHO", statImg.getSHOImg());
        statImageMap.put("DRV", statImg.getDRVImg());
        statImageMap.put("DEC", statImg.getDECImg());
        statImageMap.put("DRI", statImg.getDRIImg());
        statImageMap.put("TAC", statImg.getTACImg());
        statImageMap.put("BLD", statImg.getBLDImg());

        String upperStat = statName.toUpperCase();

        if (!statImageMap.containsKey(upperStat)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "INVALID_STAT_NAME");
        }

        boolean hasUnread = receiverRepo.existsByUserIdAndIsReadFalse(userId);

        return PageMoveResponseDto.builder()
                .status(200)
                .msg("move page : " + upperStat)
                .img(statImageMap.get(upperStat))
                .hasUnreadNotification(hasUnread)
                .build();
    }
}