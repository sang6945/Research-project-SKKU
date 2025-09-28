//package com.fineplay.fineplaybackend.playerSearch.service;
//
//import com.fineplay.fineplaybackend.auth.entity.UserEntity;
//import com.fineplay.fineplaybackend.auth.repository.UserRepository;
//import com.fineplay.fineplaybackend.playerSearch.dto.response.SearchHistoryResponseDto;
//import com.fineplay.fineplaybackend.playerSearch.entity.SearchHistoryEntity;
//import com.fineplay.fineplaybackend.playerSearch.repository.SearchHistoryRepository;
//import org.springframework.stereotype.Service;
//import java.util.List;
//import java.util.stream.Collectors;
//
//@Service
//public class SearchService {
//
//    private final UserRepository userRepository;
//    private final SearchHistoryRepository searchHistoryRepository;
//
//    public SearchService(UserRepository userRepository, SearchHistoryRepository searchHistoryRepository) {
//        this.userRepository = userRepository;
//        this.searchHistoryRepository = searchHistoryRepository;
//    }
//
//    // ✅ 닉네임 검색
//    public List<UserEntity> searchUsers(String keyword) {
//        return userRepository.findByNickName(keyword);
//    }
//
//    // ✅ 검색 기록 저장 (10개까지만 유지)
//    public void saveSearchHistory(UserEntity user, List<String> searchTexts) {
//        List<SearchHistoryEntity> history = searchHistoryRepository.findByUserOrderByCreatedAtDesc(user);
//
//        // 새로운 검색 기록 추가
//        for (String searchText : searchTexts) {
//            searchHistoryRepository.save(new SearchHistoryEntity(user, searchText));
//        }
//
//        // 검색 기록이 10개 초과 시 가장 오래된 기록 삭제
//        if (history.size() + searchTexts.size() > 10) {
//            int deleteCount = (history.size() + searchTexts.size()) - 10;
//            List<SearchHistoryEntity> toDelete = history.subList(history.size() - deleteCount, history.size());
//            searchHistoryRepository.deleteAll(toDelete);
//        }
//    }
//
//    // ✅ 검색 기록 조회
//    public SearchHistoryResponseDto getSearchHistory(UserEntity user) {
//        List<SearchHistoryEntity> history = searchHistoryRepository.findByUserOrderByCreatedAtDesc(user);
//
//        List<String> searchTexts = history.stream()
//                .map(SearchHistoryEntity::getSearchText)
//                .collect(Collectors.toList());
//
//        return new SearchHistoryResponseDto(searchTexts, "검색 기록을 가져왔습니다.");
//    }
//
//    // ✅ 검색 기록 삭제
//    public void deleteSearchHistory(UserEntity user) {
//        List<SearchHistoryEntity> history = searchHistoryRepository.findByUserOrderByCreatedAtDesc(user);
//        searchHistoryRepository.deleteAll(history);
//    }
//}
