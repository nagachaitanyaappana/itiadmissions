package com.server.backend.controller.Student;

import java.util.LinkedHashMap;
import java.util.Map;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.server.backend.service.Student.StudentPhotoService;

@Tag(name = "Student")
@RestController
@RequestMapping("/api/student")
public class StudentPhotoController {

    private final StudentPhotoService service;

    public StudentPhotoController(StudentPhotoService service) {
        this.service = service;
    }

    @Operation(summary = "Upload the candidate's photograph",
            description = "Stores (or replaces) the PNG/JPEG photograph in public.img_cand_photos "
                    + "keyed by the registration id, mirroring "
                    + "open_Application_InterfaceAction_Student.")
    @PostMapping("/photo/{regid}")
    public ResponseEntity<Map<String, Object>> uploadPhoto(
            @PathVariable Integer regid,
            @RequestParam("photo") MultipartFile photo) {
        try {
            return ResponseEntity.ok(service.savePhoto(regid, photo));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("success", false, "error", ex.getMessage()));
        }
    }

    @Operation(summary = "Read a candidate's stored photograph (base64)",
            description = "Returns the photograph stored for the registration id as base64, or "
                    + "null when none has been uploaded (edit form mirror of Editviewpage.jsp).")
    @GetMapping("/photo/{regid}")
    public ResponseEntity<Map<String, Object>> getPhoto(@PathVariable Integer regid) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("regid", regid);
        body.put("photo", service.getPhotoBase64(regid));
        return ResponseEntity.ok(body);
    }
}