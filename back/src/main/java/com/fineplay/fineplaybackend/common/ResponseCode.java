package com.fineplay.fineplaybackend.common;

public interface ResponseCode {

    // HTTP Status 200
    String SUCCESS = "SU"; // public static final 생략 가능
    String SUCCESS_FIND_USER = "SFU";

    // HTTP Status 400
    String VALIDATION_FAILED = "VF";
    String DUPLICATE_EMAIL = "DE";
    String DUPLICATE_NICKNAME = "DN";
    String DUPLICATE_PHONE_NUMBER = "DP";
    String NOT_EXISTED_USER = "NU";
    String NOT_INITIALIZED = "NI";
    String WRONG_INPUT = "WI";
    String WRONG_CODE = "WC";
    String EXIST_PHONENUMBER = "EP";

    // HTTP Status 401
    String SIGN_IN_FAIL = "SF";
    String DECRYPT_FAIL = "DF";
    String AUTHORIZATION_FAIL = "AF";
    String EXPIRED_REFRESHTOKEN = "ER";

    // HTTP Status 403
    String NO_PERMISSION = "NP";

    // HTTP Status 500
    String DATABASE_ERROR = "DBE";
}
