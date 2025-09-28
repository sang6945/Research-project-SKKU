package com.fineplay.fineplaybackend.team.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TeamUpdateRequestDto {
    private Integer teamID;
    private String teamName;
    private String homeTown1;
  private String homeTown2;
}
