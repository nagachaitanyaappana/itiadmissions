package com.server.backend.service.Student;

import java.util.List;
import java.util.Map;
import java.util.Arrays;

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
        // Do not trust the browser-supplied Content-Type or filename. Enforce the
        // configured upload limit here as well as in servlet multipart configuration.
        final long maxBytes = 5L * 1024L * 1024L;
        if (photo.getSize() > maxBytes) {
            throw new IllegalArgumentException("Photograph must not exceed 5 MB");
        }

        applicationRepository.findById(regid)
                .orElseThrow(() -> new IllegalArgumentException("Student Not Found"));

        final byte[] bytes;
        try {
            bytes = photo.getBytes();
        } catch (Exception ex) {
            throw new IllegalArgumentException("Could not read the uploaded photograph");
        }
        if (bytes.length == 0) {
            throw new IllegalArgumentException("The uploaded photograph is empty");
        }
        if (bytes.length > maxBytes) {
            throw new IllegalArgumentException("Photograph must not exceed 5 MB");
        }

        // Validate actual file signatures, not just the MIME header. PNG has a fixed
        // 8-byte signature; JPEG files begin with SOI (FF D8 FF).
        boolean isPng = bytes.length >= 8
                && Arrays.equals(Arrays.copyOf(bytes, 8),
                        new byte[] {(byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A});
        boolean isJpeg = bytes.length >= 3
                && (bytes[0] & 0xFF) == 0xFF
                && (bytes[1] & 0xFF) == 0xD8
                && (bytes[2] & 0xFF) == 0xFF;
        if (!isPng && !isJpeg) {
            throw new IllegalArgumentException("Photograph must be a valid PNG or JPEG image");
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