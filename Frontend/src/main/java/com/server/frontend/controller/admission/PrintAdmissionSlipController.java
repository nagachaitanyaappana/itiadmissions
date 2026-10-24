package com.server.frontend.controller.admission;

import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

@Controller
@RequestMapping("/admissions/print-admission-slip")
public class PrintAdmissionSlipController {

    private final RestTemplate rest = new RestTemplate();

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    @GetMapping({ "", "/" })
    public String admissionSlipView() {
        return "admission/PrintAdmissionSlip";
    }

    @GetMapping("/api/admission-slip")
    @ResponseBody
    public ResponseEntity<Object> admissionSlip(
            @RequestParam(value = "admissionNumber", required = false) String admissionNumber) {
        String adm = admissionNumber == null ? "" : admissionNumber.trim();
        if (adm.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Please enter Admission Number."));
        }

        String url = UriComponentsBuilder.fromUriString(backendBaseUrl + "/admission/admission-slip")
                .queryParam("admissionNumber", adm).toUriString();
        try {
            ResponseEntity<Object> response = rest.exchange(url, HttpMethod.GET, null,
                    new ParameterizedTypeReference<>() { });
            return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
        } catch (HttpStatusCodeException exception) {
            if (exception.getStatusCode().value() == 404) {
                return ResponseEntity.status(404)
                        .body(Map.of("error", "Admission number not found."));
            }
            return ResponseEntity.status(502)
                    .body(Map.of("error", "Unable to fetch admission slip. Please try again."));
        } catch (RestClientException exception) {
            return ResponseEntity.status(502)
                    .body(Map.of("error", "Unable to fetch admission slip. Please try again."));
        }
    }

    @GetMapping("/api/master-data")
    @ResponseBody
    public ResponseEntity<Object> masterData() {
        try {
            ResponseEntity<Object> response = rest.getForEntity(
                    backendBaseUrl + "/admission/master-data", Object.class);
            return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
        } catch (RestClientException exception) {
            return ResponseEntity.status(502)
                    .body(Map.of("error", "Unable to fetch admission master data. Please try again."));
        }
    }

    @GetMapping("/api/district/{distCode}/itis")
    @ResponseBody
    public ResponseEntity<Object> itisByDistrict(
            @PathVariable("distCode") String distCode) {
        try {
            ResponseEntity<Object> response = rest.getForEntity(
                    backendBaseUrl + "/admission/district/" + distCode.trim() + "/itis", Object.class);
            return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
        } catch (RestClientException exception) {
            return ResponseEntity.status(502)
                    .body(Map.of("error", "Unable to fetch ITIs for this district. Please try again."));
        }
    }

    @GetMapping("/api/iti/{itiCode}/trades")
    @ResponseBody
    public ResponseEntity<Object> tradesByIti(
            @PathVariable("itiCode") String itiCode) {
        try {
            ResponseEntity<Object> response = rest.getForEntity(
                    backendBaseUrl + "/admission/iti/" + itiCode.trim() + "/trades", Object.class);
            return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
        } catch (RestClientException exception) {
            return ResponseEntity.status(502)
                    .body(Map.of("error", "Unable to fetch trades for this ITI. Please try again."));
        }
    }
}
