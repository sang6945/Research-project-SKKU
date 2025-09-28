package com.fineplay.fineplaybackend.user.dto.response;

import com.fineplay.fineplaybackend.common.ResponseCode;
import com.fineplay.fineplaybackend.common.ResponseMesage;
import com.fineplay.fineplaybackend.dto.response.ResponseDto;
import com.fineplay.fineplaybackend.user.entity.UserStatEntity;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Getter
public class GetUserStatResponseDto extends ResponseDto {
    private int SPD;
    private int PAS;
    private int PAC;
    private int SHO;
    private int DRV;
    private int DEC;
    private int DRI;
    private int TAC;
    private int BLD;
    private int CRO;
    private int HED;
    private int FST;
    private int ACT;
    private int OFF;
    private int TEC;
    private int COP;
    private int OVR;

    private GetUserStatResponseDto(UserStatEntity userStatEntity) {
        super(ResponseCode.SUCCESS, ResponseMesage.SUCCESS);
        this.SPD = userStatEntity.getSPD();
        this.PAS = userStatEntity.getPAS();
        this.PAC = userStatEntity.getPAC();
        this.SHO = userStatEntity.getSHO();
        this.DRV = userStatEntity.getDRV();
        this.DEC = userStatEntity.getDEC();
        this.DRI = userStatEntity.getDRI();
        this.TAC = userStatEntity.getTAC();
        this.BLD = userStatEntity.getBLD();
        this.CRO = userStatEntity.getCRO();
        this.HED = userStatEntity.getHED();
        this.FST = userStatEntity.getFST();
        this.ACT = userStatEntity.getACT();
        this.OFF = userStatEntity.getOFF();
        this.TEC = userStatEntity.getTEC();
        this.COP = userStatEntity.getCOP();
        this.OVR = userStatEntity.getOVR();

    }

    // 성공
    public static ResponseEntity<GetUserStatResponseDto> success(UserStatEntity userStatEntity) {
        GetUserStatResponseDto result = new GetUserStatResponseDto(userStatEntity);
        return ResponseEntity.status(HttpStatus.OK).body(result);
    }

    // 유저 정보 없음
    public static ResponseEntity<ResponseDto> notExistUser() {
        ResponseDto result = new ResponseDto(ResponseCode.NOT_EXISTED_USER, ResponseMesage.NOT_EXISTED_USER);
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(result);
    }
}
