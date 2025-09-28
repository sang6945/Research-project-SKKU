package com.fineplay.fineplaybackend.team.controller;

import com.fineplay.fineplaybackend.provider.JwtProvider;
import com.fineplay.fineplaybackend.team.dto.request.*;
import com.fineplay.fineplaybackend.team.dto.response.*;
import com.fineplay.fineplaybackend.team.repository.TeamRequestListRepository;
import com.fineplay.fineplaybackend.team.repository.TeamRepository;
import com.fineplay.fineplaybackend.team.service.TeamService;
import com.fineplay.fineplaybackend.auth.entity.UserEntity;
import com.fineplay.fineplaybackend.auth.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/team")
@RequiredArgsConstructor
public class TeamController {

    private final TeamService teamService;
    private final JwtProvider jwtProvider;
    private final UserRepository userRepository;
    private final TeamRepository teamRepository;
    private final TeamRequestListRepository TeamRequestListRepository;

    /**
     * JWT 토큰 검증 공통 메서드 (모든 API에서 사용)
     */
    private String validateJwt(HttpServletRequest request) {
        String token = jwtProvider.getTokenFromRequest(request);
        if (token == null) {
            throw new IllegalArgumentException("JWT 검증 실패: 토큰이 없습니다.");
        }
        String email = jwtProvider.validateJwt(token);
        if (email == null) {
            throw new IllegalArgumentException("JWT 검증 실패: 유효하지 않은 토큰입니다.");
        }
        return email;
    }

    /**
     * 팀 이름 중복 확인 (JWT 인증 필수)
     * GET /api/team/nameDuplicate?TeamName=팀명
     */
    @GetMapping("/nameDuplicate")
    public ResponseEntity<?> checkTeamNameDuplicate(HttpServletRequest request, @RequestParam("TeamName") String teamName) {
        try {
            validateJwt(request);
            boolean available = !teamRepository.existsByTeamName(teamName);
            if (!available) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "중복된 팀 이름", new TeamNameDuplicateResponseDto(false, null)));
            }
            return ResponseEntity.ok(new ApiResponse<>(200, "사용 가능한 팀 이름", new TeamNameDuplicateResponseDto(true, null)));
        } catch (Exception e) {
            return ResponseEntity.status(401)
                    .body(new ApiResponse<>(401, e.getMessage(), null));
        }
    }

    /**
     * 팀 생성 (JWT 인증 필수)
     * POST /api/team/teamMake
     */
    @PostMapping("/teamMake")
    public ResponseEntity<?> createTeam(HttpServletRequest request,
                                        @RequestBody @Valid CreateTeamRequestDto requestDto,
                                        BindingResult bindingResult) {
        try {
            validateJwt(request);
            Long userId = jwtProvider.getUserIdFromRequest(request);
            if (bindingResult.hasErrors()) {
                List<FieldError> errors = bindingResult.getFieldErrors();
                List<FieldErrorDto> errorDetails = errors.stream()
                        .map(error -> new FieldErrorDto(error.getField(), error.getRejectedValue(), error.getDefaultMessage()))
                        .collect(Collectors.toList());
                return ResponseEntity.badRequest().body(new FieldErrorResponse(errorDetails));
            }
            TeamCreationResponseDto creationResponse = teamService.createTeam(requestDto, userId);
            if (creationResponse.getErrCode() != null) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "Duplicate team name.", null));
            }
            return ResponseEntity.ok(new ApiResponse<>(200, "팀 생성 성공", creationResponse));
        } catch (Exception e) {
            return ResponseEntity.status(401)
                    .body(new ApiResponse<>(401, e.getMessage(), null));
        }
    }

    /**
     * 마이 팀 리스트 조회 (JWT 인증 필수)
     * GET /api/team/MyTeamList
     */
    @GetMapping("/MyTeamList")
    public ResponseEntity<?> getMyTeams(HttpServletRequest request) {
        try {
            String email = validateJwt(request);
            UserEntity user = userRepository.findByEmail(email);
            if (user == null) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "사용자를 찾을 수 없습니다.", null));
            }
            return ResponseEntity.ok(teamService.getMyTeams(user.getUserId()));
        } catch (Exception e) {
            return ResponseEntity.status(401)
                    .body(new ApiResponse<>(401, e.getMessage(), null));
        }
    }

    /**
     * 팀 가입 신청 (JWT 인증 필수)
     * POST /api/team/RegisterRequest
     */
    @PostMapping("/RegisterRequest")
    public ResponseEntity<?> requestJoinTeam(HttpServletRequest request, @RequestBody TeamJoinRequestDto requestDto) {
        try {
            Long userId = jwtProvider.getUserIdFromRequest(request);
            if (userId == null) {
                return ResponseEntity.status(401)
                        .body(new ApiResponse<>(401, "JWT 검증 실패: 사용자 인증이 필요합니다.", null));
            }
            if (requestDto.getTeamId() == null) {
                return ResponseEntity.status(400)
                        .body(new ApiResponse<>(400, "팀 ID는 필수 입력값입니다.", null));
            }
            String result = teamService.requestJoinTeam(userId, requestDto.getTeamId());
            if ("ALREADY_IN_TEAM".equals(result)) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "이미 가입된 팀입니다.", null));
            }
            if ("ALREADY_REQUESTED".equals(result)) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "이미 가입 신청한 상태입니다.", null));
            }
            if ("USER_NOT_FOUND".equals(result)) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "사용자를 찾을 수 없습니다.", null));
            }
            if ("TEAM_NOT_FOUND".equals(result)) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "팀을 찾을 수 없습니다.", null));
            }
            return ResponseEntity.ok(new ApiResponse<>(200, "팀 가입 신청 완료", result));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400)
                    .body(new ApiResponse<>(400, e.getMessage(), null));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409)
                    .body(new ApiResponse<>(409, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "서버 내부 오류", null));
        }
    }

    /**
     * 팀 가입 신청 목록 조회 (JWT 인증 필수)
     * POST /api/team/TeamRegisterManage
     */
    @PostMapping("/TeamRegisterManage")
    public ResponseEntity<?> getTeamJoinRequests(HttpServletRequest request, @RequestBody TeamManageRequestDto requestDto) {
        try {
            Long leaderId = jwtProvider.getUserIdFromRequest(request);
            Long teamId = requestDto.getTeamId();
            if (teamId == null) {
                return ResponseEntity.status(400)
                        .body(new ApiResponse<>(400, "팀 ID는 필수 입력값입니다.", null));
            }
            List<TeamRegisterManageResponseDto> response = teamService.getTeamJoinRequests(teamId, leaderId);
            return ResponseEntity.ok(new ApiResponse<>(200, "가입 신청 목록 조회 성공", response));
        } catch (Exception e) {
            return ResponseEntity.status(401)
                    .body(new ApiResponse<>(401, "JWT 검증 실패: " + e.getMessage(), null));
        }
    }

    /**
     * 팀 가입 수락 (JWT 인증 필수)
     * POST /api/team/TeamAccept
     */
    @PostMapping("/TeamAccept")
    public ResponseEntity<?> acceptJoinRequest(HttpServletRequest request, @RequestBody TeamJoinActionDto actionDto) {
        try {
            Long leaderId = jwtProvider.getUserIdFromRequest(request);
            if (actionDto.getTeamId() == null || actionDto.getUserId() == null) {
                return ResponseEntity.status(400)
                        .body(new ApiResponse<>(400, "팀 ID와 사용자 ID는 필수 입력값입니다.", null));
            }
            String result = teamService.acceptJoinRequest(actionDto.getTeamId(), actionDto.getUserId(), leaderId);
            if ("TEAM_NOT_FOUND".equals(result)) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "팀을 찾을 수 없습니다.", null));
            }
            if ("NOT_TEAM_LEADER".equals(result)) {
                return ResponseEntity.status(403)
                        .body(new ApiResponse<>(403, "팀장이 아닙니다.", null));
            }
            if ("USER_NOT_FOUND".equals(result)) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "사용자를 찾을 수 없습니다.", null));
            }
            if ("USER_ALREADY_IN_MAX_TEAMS".equals(result)) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "사용자가 이미 최대 팀 수에 도달했습니다.", null));
            }
            if ("NO_JOIN_REQUEST".equals(result)) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "가입 신청 목록에 해당 사용자가 없습니다.", null));
            }
            if ("JOIN_ACCEPTED".equals(result)) {
                return ResponseEntity.ok(new ApiResponse<>(200, "가입 요청 승인 완료", result));
            }
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "알 수 없는 오류", null));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400)
                    .body(new ApiResponse<>(400, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "서버 내부 오류", null));
        }
    }

    /**
     * 팀 가입 거절 (JWT 인증 필수)
     * POST /api/team/TeamReject
     */
    @PostMapping("/TeamReject")
    public ResponseEntity<?> rejectJoinRequest(HttpServletRequest request, @RequestBody TeamJoinActionDto actionDto) {
        try {
            Long leaderId = jwtProvider.getUserIdFromRequest(request);
            if (actionDto.getTeamId() == null || actionDto.getUserId() == null) {
                return ResponseEntity.status(400)
                        .body(new ApiResponse<>(400, "팀 ID와 사용자 ID는 필수 입력값입니다.", null));
            }
            String result = teamService.rejectJoinRequest(actionDto.getTeamId(), actionDto.getUserId(), leaderId);
            if ("TEAM_NOT_FOUND".equals(result)) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "팀을 찾을 수 없습니다.", null));
            }
            if ("NOT_TEAM_LEADER".equals(result)) {
                return ResponseEntity.status(403)
                        .body(new ApiResponse<>(403, "팀장이 아닙니다.", null));
            }
            if ("NO_JOIN_REQUEST".equals(result)) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "가입 신청 목록에 해당 사용자가 없습니다.", null));
            }
            if ("JOIN_REJECTED".equals(result)) {
                return ResponseEntity.ok(new ApiResponse<>(200, "가입 요청 거절 완료", result));
            }
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "알 수 없는 오류", null));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400)
                    .body(new ApiResponse<>(400, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "서버 내부 오류", null));
        }
    }

    /**
     * 팀원 목록 조회 (JWT 인증 필수)
     * POST /api/team/TeamMemberList
     */
    @PostMapping("/TeamMemberList")
    public ResponseEntity<?> getTeamMembers(HttpServletRequest request, @RequestBody TeamMemberRequestDto requestDto) {
        try {
            validateJwt(request);
            List<TeamMemberListResponseDto> members = teamService.getTeamMembers(requestDto.getTeamId());
            return ResponseEntity.ok(new ApiResponse<>(200, "팀원 목록", members));
        } catch (Exception e) {
            return ResponseEntity.status(401)
                    .body(new ApiResponse<>(401, e.getMessage(), null));
        }
    }
    /**
     * 팀 정보 수정
     * POST /api/team/TeamUpdate
     */
    @PutMapping("/TeamUpdate")
    public ResponseEntity<?> updateTeamInfo(HttpServletRequest request, @RequestBody TeamUpdateRequestDto updateDto) {
        try {
            // JWT 검증 및 요청 사용자의 팀 리더 여부 확인
            Long leaderId = jwtProvider.getUserIdFromRequest(request);
            if (updateDto.getTeamID() == null || updateDto.getTeamName() == null
                    || updateDto.getHomeTown1() == null || updateDto.getHomeTown2() == null) {
                return ResponseEntity.status(400)
                        .body(new ApiResponse<>(400, "필수 값(teamID, teamName, HomeTown1, HomeTown2) 누락", null));
            }
            // 서비스에서 팀 정보 수정 처리 (팀 리더만 수정 가능하도록 내부에서 검증)
            String result = teamService.updateTeamInfo(updateDto, leaderId);
            if ("TEAM_NOT_FOUND".equals(result)) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "팀을 찾을 수 없습니다.", null));
            }
            if ("NOT_TEAM_LEADER".equals(result)) {
                return ResponseEntity.status(403)
                        .body(new ApiResponse<>(403, "팀장이 아닙니다.", null));
            }
            if ("DUPLICATE_TEAM_NAME".equals(result)) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "중복된 팀 이름입니다.", null));
            }
            if ("TEAM_UPDATE_SUCCESS".equals(result)) {
                return ResponseEntity.ok(new ApiResponse<>(200, "team info update success", null));
            }
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "알 수 없는 오류", null));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400)
                    .body(new ApiResponse<>(400, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "서버 내부 오류", null));
        }
    }

    @PostMapping("/TeamLeave")
    public ResponseEntity<?> leaveTeam(HttpServletRequest request, @RequestBody TeamLeaveRequestDto leaveDto) {
        try {
            // JWT 검증 및 JWT에서 사용자 ID 추출
            Long jwtUserId = jwtProvider.getUserIdFromRequest(request);
            if (leaveDto.getTeamId() == null || leaveDto.getUserId() == null) {
                return ResponseEntity.status(400)
                        .body(new ApiResponse<>(400, "팀 ID와 사용자 ID는 필수 입력값입니다.", null));
            }
            // 본인 여부 확인: JWT의 사용자 ID와 요청 본문의 userId가 동일해야 함.
            if (!jwtUserId.equals(leaveDto.getUserId())) {
                return ResponseEntity.status(403)
                        .body(new ApiResponse<>(403, "본인만 팀 탈퇴를 요청할 수 있습니다.", null));
            }

            // 팀 탈퇴 처리
            String result = teamService.leaveTeam(leaveDto.getTeamId(), leaveDto.getUserId());
            if ("TEAM_NOT_FOUND".equals(result)) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "팀을 찾을 수 없습니다.", null));
            }
            if ("USER_NOT_FOUND".equals(result)) {
                return ResponseEntity.status(404)
                        .body(new ApiResponse<>(404, "사용자를 찾을 수 없습니다.", null));
            }
            if ("USER_NOT_IN_TEAM".equals(result)) {
                return ResponseEntity.status(409)
                        .body(new ApiResponse<>(409, "해당 사용자가 팀에 속해 있지 않습니다.", null));
            }
            if ("TEAM_LEAVE_SUCCESS".equals(result)) {
                return ResponseEntity.ok(new ApiResponse<>(200, "팀 탈퇴 성공", new Object[]{ new ErrCode(null) }));
            }
            if ("TEAM_LEAVE_DELETE_SUCCESS".equals(result)) {
                return ResponseEntity.ok(new ApiResponse<>(200, "팀 탈퇴 및 팀 삭제 성공", new Object[]{ new ErrCode(null) }));
            }
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "알 수 없는 오류", null));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400)
                    .body(new ApiResponse<>(400, e.getMessage(), null));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(new ApiResponse<>(500, "서버 내부 오류", null));
        }
    }

    @GetMapping("/search")
    public ResponseEntity<?> searchTeams(HttpServletRequest request, @RequestParam("SearchContent") String searchContent) {
        try {
            validateJwt(request);

            List<TeamSearchResponseDto> teams = teamService.searchTeams(searchContent);
            return ResponseEntity.ok(new ApiResponse<>(200, "검색된 팀 정보리스트", teams));
        } catch(Exception e) {
            return ResponseEntity.status(500).body(new ApiResponse<>(500, "서버 내부 오류", null));
        }
    }






    @Getter
    @Setter
    @AllArgsConstructor
    private static class ApiResponse<T> {
        private int code;
        private String message;
        private T data;
    }

    @Getter
    @Setter
    @AllArgsConstructor
    public class ErrCode {
        private String errCode;
    }
}
