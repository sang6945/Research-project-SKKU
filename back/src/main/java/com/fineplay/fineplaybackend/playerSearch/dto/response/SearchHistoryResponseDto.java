//package com.fineplay.fineplaybackend.playerSearch.dto.response;
//
//import lombok.Getter;
//import lombok.Setter;
//import java.util.List;
//
//@Getter
//@Setter
//public class SearchHistoryResponseDto {
//    private List<String> searchTexts;
//    private String message;
//
//    // 기존 메시지만 받는 생성자 유지
//    public SearchHistoryResponseDto(String message) {
//        this.message = message;
//    }
//
//    // ✅ 검색 기록을 포함하는 생성자 추가
//    public SearchHistoryResponseDto(List<String> searchTexts, String message) {
//        this.searchTexts = searchTexts;
//        this.message = message;
//    }
//}
