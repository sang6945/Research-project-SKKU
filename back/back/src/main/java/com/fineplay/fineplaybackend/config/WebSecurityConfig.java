package com.fineplay.fineplaybackend.config;

import static org.springframework.security.config.Customizer.withDefaults;

import com.fineplay.fineplaybackend.filter.JwtAuthenticationFilter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.CsrfConfigurer;
import org.springframework.security.config.annotation.web.configurers.HttpBasicConfigurer;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.stereotype.Component;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
//@EnableWebFluxSecurity
@RequiredArgsConstructor
public class WebSecurityConfig {
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final FailedAuthenticationEntryPoint failedAuthenticationEntryPoint;

//    private final String[] swaggerPath = {"/swagger-ui/**", "/v3/api-docs", "/v3/api-docs/**", "/v3/api-docs.yaml"};

    @Bean
    public SecurityFilterChain configure(HttpSecurity httpSecurity) throws Exception {
        httpSecurity
                .cors(cors -> cors.configurationSource(corsConfigurationSource())) // CORS 설정
//                .csrf(csrf -> csrf.disable()) // CSRF 비활성화
                .csrf(CsrfConfigurer::disable)
//                .httpBasic(httpBasic -> httpBasic.disable()) // HTTP Basic 인증 비활성화
                .httpBasic(HttpBasicConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // 세션 정책
                .authorizeHttpRequests(request -> request
                        .requestMatchers("/", "/api/auth/**", "https://fine-play.github.io/*").permitAll() // 특정 요청 허용
//                        .requestMatchers(swaggerPath).permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/team/nameDuplicate").permitAll() // GET 요청 허용
                        .anyRequest().authenticated() // 그 외 인증 필요
                )
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint(failedAuthenticationEntryPoint) // 인증 실패 핸들링
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return httpSecurity.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.addAllowedOriginPattern("*");
//        configuration.addAllowedOrigin("*"); // 모든 도메인 허용
//        configuration.addAllowedOrigin("http://localhost:8080");
        configuration.addAllowedMethod("*"); // 모든 HTTP 메서드 허용
        configuration.addAllowedHeader("*"); // 모든 헤더 허용
        configuration.setAllowCredentials(true); // 인증 정보 포함 허용

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}

// 인증 실패 처리
@Component
class FailedAuthenticationEntryPoint implements AuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException, ServletException {
        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.getWriter().write("{ \"code\": \"AF\", \"message\": \"Authorization Failed.\" }");
    }
}
