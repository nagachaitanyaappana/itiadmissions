package com.server.backend.controller.Admission;

import com.server.backend.service.Admission.DistrictVerifyService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@Tag(name = "District Verification")
@RestController
@RequestMapping("/api/dv")
public class DistrictVerifyController {

    private final DistrictVerifyService service;

    public DistrictVerifyController(DistrictVerifyService service) {
        this.service = service;
    }

    @GetMapping("/lookup")
    public Map<String, Object> lookup(@RequestParam String regid,
                                       @RequestParam(required = false) String distCode) {
        return service.lookup(regid, distCode);
    }

    @PostMapping("/approve")
    public Map<String, Object> approve(@RequestBody Map<String, Object> body,
                                       HttpServletRequest request) {
        return service.approve(
                (String) body.get("regid"),
                (String) body.get("distCode"),
                (String) body.get("username"),
                request.getRemoteAddr(),
                (Map<String, String>) body.get("documents")
        );
    }

    @PostMapping("/reject")
    public Map<String, Object> reject(@RequestBody Map<String, String> body,
                                      HttpServletRequest request) {
        return service.reject(
                body.get("regid"),
                body.get("distCode"),
                body.get("username"),
                body.get("reason"),
                request.getRemoteAddr()
        );
    }
}