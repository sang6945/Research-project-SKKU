package com.fineplay.fineplaybackend.match.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;


@Getter
@AllArgsConstructor
@NoArgsConstructor
public class RecentMatchRecordResponseDto {
    private int recentWin;
    private int recentDraw;
    private int recentLose;
}



