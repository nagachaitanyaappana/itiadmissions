package com.server.backend.service.Student;

import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.server.backend.Repository.Student.StudentApplicationRepository;

/**
 * Stores the candidate's photograph in {@code public.img_cand_photos} (regid integer, pic bytea),
 * mirroring {@code open_Application_InterfaceAction_Student}: if a row already exists for the
 * registration id the {@code pic} bytea is replaced, otherwise a new row is inserted. The legacy
 * action only accepted image/png and image/jpeg, so the same whitelist applies here.
 */
@Service
public class StudentPhotoService {

    private final JdbcTemplate jdbcTemplate;
    private final StudentApplicationRepository applicationRepository;

    public StudentPhotoService(JdbcTemplate jdbcTemplate,
            StudentApplicationRepository applicationRepository) {
        this.jdbcTemplate = jdbcTemplate;
        this.applicationRepository = applicationRepository;
    }

    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> savePhoto(Integer regid, MultipartFile photo) {
        if (regid == null || regid <= 0) {
            throw new IllegalArgumentException("A valid Registration Id is required");
        }
        if (photo == null || photo.isEmpty()) {
            throw new IllegalArgumentException("Please select a photograph to upload");
        }
        String contentType = photo.getContentType();
        boolean isPng = "image/png".equalsIgnoreCase(contentType);
        boolean isJpeg = "image/jpeg".equalsIgnoreCase(contentType);
        if (!isPng && !isJpeg) {
            throw new IllegalArgumentException(
                    "Photograph must be a PNG or JPEG image (received " + contentType + ")");
        }

        applicationRepository.findById(regid)
                .orElseThrow(() -> new RuntimeException("Student Not Found"));

        byte[] bytes;
        try {
            bytes = photo.getBytes();
        } catch (Exception ex) {
            throw new IllegalArgumentException("Could not read the uploaded photograph");
        }
        if (bytes.length == 0) {
            throw new IllegalArgumentException("The uploaded photograph is empty");
        }

        Integer existing = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM img_cand_photos WHERE regid = ?", Integer.class, regid);
        if (existing != null && existing > 0) {
            jdbcTemplate.update("UPDATE img_cand_photos SET pic = ? WHERE regid = ?", bytes, regid);
        } else {
            jdbcTemplate.update("INSERT INTO img_cand_photos (regid, pic) VALUES (?, ?)", regid, bytes);
        }

        return Map.of("success", true, "regid", regid,
                "message", "Photograph uploaded successfully");
    }

    /** Base64 of the stored photograph (newlines stripped) or null when none was uploaded. */
    @Transactional(readOnly = true)
    public String getPhotoBase64(Integer regid) {
        if (regid == null || regid <= 0) {
            throw new IllegalArgumentException("A valid Registration Id is required");
        }
        List<String> photos = jdbcTemplate.queryForList(
                "SELECT translate(encode(pic, 'base64'), E'\\n', '') "
                        + "FROM img_cand_photos WHERE regid = ? LIMIT 1",
                String.class, regid);
        if (photos.isEmpty() || photos.get(0) == null) {
            return null;
        }
        return photos.get(0).replace("\r", "").replace("\n", "");
    }
}