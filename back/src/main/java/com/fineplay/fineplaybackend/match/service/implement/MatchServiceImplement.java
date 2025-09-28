package com.fineplay.fineplaybackend.match.service.implement;

import com.fineplay.fineplaybackend.match.dto.response.RecentMatchRecordResponseDto;
import com.fineplay.fineplaybackend.match.entity.MatchesEntity;
import com.fineplay.fineplaybackend.match.repository.MatchesRepository;
import com.fineplay.fineplaybackend.match.service.MatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class MatchServiceImplement implements MatchService {

    private final MatchesRepository matchesRepository;

    @Override
    public RecentMatchRecordResponseDto getRecentMatchRecord(Long teamId) {
        List<MatchesEntity> matches = matchesRepository
                .findTop15ByHomeTeamIdOrAwayTeamIdOrderByMatchDateDesc(teamId, teamId);

        int win = 0, draw = 0;
        for (MatchesEntity match : matches) {
            if (Long.valueOf(-1).equals(match.getResult())) {
                draw++;
            } else if (teamId.equals(match.getResult())) {
                win++;
            }
        }
        int lose = matches.size() - win - draw;

        return new RecentMatchRecordResponseDto(win, draw, lose);
    }
}
