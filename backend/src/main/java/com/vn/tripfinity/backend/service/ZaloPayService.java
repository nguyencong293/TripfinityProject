package com.vn.tripfinity.backend.service;

import java.math.BigDecimal;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vn.tripfinity.backend.config.ZaloPayProperties;
import com.vn.tripfinity.backend.util.HmacUtil;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ZaloPayService {

    private final ZaloPayProperties props;
    private final ObjectMapper mapper = new ObjectMapper();

    // Format yyMMdd_random6 per docs
    private String genAppTransId() {
        String date = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).format(DateTimeFormatter.ofPattern("yyMMdd"));
        long suffix = (long) (Math.random() * 900000L) + 100000L;
        return date + "_" + suffix;
    }

    public Map<String, Object> createOrder(BigDecimal amount, String appUser, String description) {
        long vnd = amount.setScale(0, java.math.RoundingMode.HALF_UP).longValue();
        String apptransid = genAppTransId();
        long apptime = System.currentTimeMillis();
        String item = "[]";
        String embeddata = "{}";

        // data = appid|apptransid|appuser|amount|apptime|embeddata|item
        String data = String.join("|",
                props.getAppid(),
                apptransid,
                appUser,
                String.valueOf(vnd),
                String.valueOf(apptime),
                embeddata,
                item);
        String mac = HmacUtil.hmacSha256Hex(props.getKey1(), data);

        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("appid", props.getAppid());
        form.add("apptransid", apptransid);
        form.add("appuser", appUser);
        form.add("amount", String.valueOf(vnd));
        form.add("apptime", String.valueOf(apptime));
        form.add("embeddata", embeddata);
        form.add("item", item);
        form.add("description", description != null ? description : "Tripfinity hotel payment");
        form.add("bankcode", ""); // Empty = show all payment options (ZaloPay app, credit card, ATM)
        // Optional but useful for redirect and IPN testing
        if (props.getCallbackUrl() != null && !props.getCallbackUrl().isEmpty()) {
            form.add("callback_url", props.getCallbackUrl());
        }
        if (props.getReturnUrl() != null && !props.getReturnUrl().isEmpty()) {
            form.add("redirect_url", props.getReturnUrl());
        }
        form.add("mac", mac);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(form, headers);

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.postForEntity(props.getEndpoint(), request, String.class);
        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new RuntimeException("ZaloPay HTTP " + response.getStatusCode());
        }
        String body = response.getBody();
        try {
            JsonNode json = mapper.readTree(body);
            // ZaloPay actually returns "returncode" (no underscore) not "return_code"
            int code = json.path("returncode").asInt(-1);
            if (code != 1) {
                String msg = json.path("returnmessage").asText("");
                log.error("ZaloPay createorder failed: {} - {} | resp={} ", code, msg, body);
                throw new RuntimeException("ZaloPay error: " + msg);
            }
            Map<String, Object> out = new HashMap<>();
            // Response also uses "orderurl" not "order_url"
            out.put("order_url", json.path("orderurl").asText());
            out.put("apptransid", apptransid);
            return out;
        } catch (Exception e) {
            log.error("Parse ZaloPay response failed, raw body: {}", body);
            throw new RuntimeException("Parse ZaloPay response failed", e);
        }
    }
}
