package com.fineplay.fineplaybackend.exception;

import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

import java.util.LinkedHashMap;
import java.util.Map;

@RestControllerAdvice
public class BadRequestExceptionHandler {

    @ExceptionHandler({MethodArgumentNotValidException.class, HttpMessageNotReadableException.class})
    public ResponseEntity<ResponseDto> validationExceptionHandler(Exception exception) {
        return ResponseDto.validationFailed();
    }

    //Mypage관련 error
    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, Object>> handleResponseStatusException(ResponseStatusException exception) {
        String reason = exception.getReason();
        Map<String, Object> errorResponse = new LinkedHashMap<>(); // ✅ 순서 보장됨

        if ("INVALID_USER_ID".equals(reason)) {
            errorResponse.put("errCode", "INVALID_USER_ID");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "유효하지 않은 UserId");
        }
        else if("INVALID_USER_ID_FOR_USER_STAT".equals(reason)) {
            errorResponse.put("errCode", "INVALID_USER_ID_FOR_USER_STAT");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "User Stat에 없는 UserId");
        }
        else if ("INVALID_SELECTED_STAT".equals(reason)) {
            errorResponse.put("errCode", "INVALID_SELECTED_STAT");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "선택된 스탯이 유효하지 않습니다.");
        }
        else if ("INVALID_STAT_NAME".equals(reason)) {
            errorResponse.put("errCode", "INVALID_STAT_NAME");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "스탯 이름이 유효하지 않습니다.");
        }
        else if ("INVALID_USER_ID_MISMATCH".equals(reason)) {
            errorResponse.put("errCode", "INVALID_USER_ID_MISMATCH");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "요청된 userId가 토큰 userId와 일치하지 않습니다.");
        }

        // 팀 관련 오류 처리 추가
        else if ("USER_ID_NULL".equals(reason)) {
            errorResponse.put("errCode", "USER_ID_NULL");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "userId가 null입니다.");
        }
        else if ("DUPLICATE_TEAM_NAME".equals(reason)) {
            errorResponse.put("errCode", "DUPLICATE_TEAM_NAME");
            errorResponse.put("statusCode", 409);
            errorResponse.put("responseMessage", "중복된 팀 이름입니다.");
        }
        else if ("TEAM_NOT_FOUND".equals(reason)) {
            errorResponse.put("errCode", "TEAM_NOT_FOUND");
            errorResponse.put("statusCode", 404);
            errorResponse.put("responseMessage", "팀을 찾을 수 없습니다.");
        }
        else if ("USER_NOT_FOUND".equals(reason)) {
            errorResponse.put("errCode", "USER_NOT_FOUND");
            errorResponse.put("statusCode", 404);
            errorResponse.put("responseMessage", "사용자를 찾을 수 없습니다.");
        }
        else if ("ALREADY_REQUESTED".equals(reason)) {
            errorResponse.put("errCode", "ALREADY_REQUESTED");
            errorResponse.put("statusCode", 409);
            errorResponse.put("responseMessage", "이미 가입 신청한 상태입니다.");
        }
        else if ("ALREADY_IN_TEAM".equals(reason)) {
            errorResponse.put("errCode", "ALREADY_IN_TEAM");
            errorResponse.put("statusCode", 409);
            errorResponse.put("responseMessage", "이미 가입된 팀입니다.");
        }
        else if ("NO_JOIN_REQUEST".equals(reason)) {
            errorResponse.put("errCode", "NO_JOIN_REQUEST");
            errorResponse.put("statusCode", 409);
            errorResponse.put("responseMessage", "가입 신청 목록에 해당 사용자가 없습니다.");
        }
        else if ("NOT_TEAM_LEADER".equals(reason)) {
            errorResponse.put("errCode", "NOT_TEAM_LEADER");
            errorResponse.put("statusCode", 403);
            errorResponse.put("responseMessage", "팀장이 아닙니다.");
        }
        // 추가된 오류 처리
        else if ("USER_ALREADY_IN_MAX_TEAMS".equals(reason)) {
            errorResponse.put("errCode", "USER_ALREADY_IN_MAX_TEAMS");
            errorResponse.put("statusCode", 409);
            errorResponse.put("responseMessage", "사용자는 최대 3개의 팀에만 가입할 수 있습니다.");
        }
        else if ("NEW_LEADER_NOT_FOUND".equals(reason)) {
            errorResponse.put("errCode", "NEW_LEADER_NOT_FOUND");
            errorResponse.put("statusCode", 404);
            errorResponse.put("responseMessage", "새 팀 리더를 찾을 수 없습니다.");
        }
        else if ("TEAM_LEADER_CANNOT_LEAVE".equals(reason)) {
            errorResponse.put("errCode", "TEAM_LEADER_CANNOT_LEAVE");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "팀장은 팀을 탈퇴할 수 없습니다.");
        }
        else if ("TEAM_LEADER_MUST_ASSIGN_NEW_LEADER".equals(reason)) {
            errorResponse.put("errCode", "TEAM_LEADER_MUST_ASSIGN_NEW_LEADER");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "팀장을 변경하려면 새로운 팀 리더를 지정해야 합니다.");
        }
        else if ("CURRENT_TEAM_NOT_FOUND".equals(reason)) {
            errorResponse.put("errCode", "CURRENT_TEAM_NOT_FOUND");
            errorResponse.put("statusCode", 404);
            errorResponse.put("responseMessage", "현재 소속된 팀을 찾을 수 없습니다.");
        }
        else if ("TEAM_STAT_NOT_FOUND".equals(reason)) {
            errorResponse.put("errCode", "TEAM_STAT_NOT_FOUND");
            errorResponse.put("statusCode", 404);
            errorResponse.put("responseMessage", "팀 스탯 정보를 찾을 수 없습니다.");
        }
        // 요청된 teamId가 해당 경기의 홈/어웨이팀에 모두 속하지 않을 때
        else if ("TEAM_NOT_IN_MATCH".equals(reason)) {
            errorResponse.put("errCode", "TEAM_NOT_IN_MATCH");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "해당 팀이 이 경기의 홈팀 또는 어웨이팀이 아닙니다.");
        }
        // 유효하지 않은 matchId일 때
        else if ("INVALID_MATCH_ID".equals(reason)) {
            errorResponse.put("errCode", "INVALID_MATCH_ID");
            errorResponse.put("statusCode", 400);
            errorResponse.put("responseMessage", "유효하지 않은 MatchId");
        }


        else {
            throw exception; // 다른 예외는 그대로 던짐
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }
}
