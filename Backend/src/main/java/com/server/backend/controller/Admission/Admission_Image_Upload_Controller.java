package com.server.backend.controller.Admission;

import com.server.backend.config.JwtAuthenticationFilter;
import com.server.backend.DTO.Admission_Image_Upload_DTO;
import com.server.backend.service.Admission.Admission_Image_Upload_Service;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/admission")
public class Admission_Image_Upload_Controller {

    private final Admission_Image_Upload_Service service;

    public Admission_Image_Upload_Controller(Admission_Image_Upload_Service service) {
        this.service = service;
    }

    @GetMapping("/admission-image-upload")
    public ResponseEntity<Admission_Image_Upload_DTO> verifyAdmission(
            @RequestParam String admissionNumber,
            @RequestParam String sscHallticketNumber,
            @RequestParam(required = false) String itiCode,
            HttpServletRequest request) {

        Object value = request.getAttribute(JwtAuthenticationFilter.CLAIMS_ATTRIBUTE);
        if (value instanceof Claims claims) {
            String role = String.valueOf(claims.get("roleId"));
            String scope = claims.get("insCode") == null ? "" : String.valueOf(claims.get("insCode"));
            if ("4".equals(role)) {
                itiCode = scope;
            } else if (!"2".equals(role) && !"10".equals(role)) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "Only the assigned ITI or an authorized state/nodal official may verify this admission");
            }
        }
        if (itiCode == null || itiCode.isBlank()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "An ITI scope is required");
        }

        try {
            return ResponseEntity.ok(service.verifyAdmission(
                    admissionNumber, sscHallticketNumber, itiCode.trim()));
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, ex.getMessage());
        }
    }
}
