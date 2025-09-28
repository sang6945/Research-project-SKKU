//package com.fineplay.fineplaybackend.config;
//
//import io.swagger.v3.oas.annotations.OpenAPIDefinition;
//import io.swagger.v3.oas.annotations.info.Info;
//import io.swagger.v3.oas.models.Components;
//import io.swagger.v3.oas.models.OpenAPI;
//import io.swagger.v3.oas.models.security.SecurityRequirement;
//import io.swagger.v3.oas.models.security.SecurityScheme;
//import java.util.Arrays;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//
//@OpenAPIDefinition(
//        info = @Info(title = "Fine-play API",
//                description = "fine play의 api 명세 문서입니다.",
//                version = "v1"))
//@Configuration
//public class SwaggerConfig {
//
//    @Bean
//    public OpenAPI openAPI(){
//        // Authorization 헤더 방식 (Bearer 토큰)
//        SecurityScheme bearerScheme = new SecurityScheme()
//                .type(SecurityScheme.Type.HTTP)
//                .scheme("bearer")
//                .bearerFormat("JWT")
//                .in(SecurityScheme.In.HEADER)
//                .name("Authorization");
//
////        // refreshToken 쿠키 방식
////        SecurityScheme cookieScheme = new SecurityScheme()
////                .type(SecurityScheme.Type.APIKEY)
////                .in(SecurityScheme.In.COOKIE)
////                .name("refreshToken");
//
//        SecurityRequirement securityRequirement = new SecurityRequirement()
//                .addList("bearerAuth");
////                .addList("refreshToken");
//
//
//        return new OpenAPI()
//                .components(new Components()
//                        .addSecuritySchemes("bearerAuth", bearerScheme)
////                        .addSecuritySchemes("refreshToken", cookieScheme)
//                )
//                .security(Arrays.asList(securityRequirement));
//    }
//
//}