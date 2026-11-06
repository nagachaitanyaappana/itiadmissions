package com.server.backend.service.Student;

import static org.junit.jupiter.api.Assertions.*;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import javax.imageio.ImageIO;

import org.junit.jupiter.api.Test;

class CandidatePhotoValidatorTest {

    @Test
    void acceptsAndNormalizesPng() throws Exception {
        byte[] input = image("png", 32, 24);
        byte[] output = CandidatePhotoValidator.validateAndNormalize(input);

        assertNotNull(ImageIO.read(new java.io.ByteArrayInputStream(output)));
        assertEquals("png", ImageIO.getImageReaders(
                ImageIO.createImageInputStream(new java.io.ByteArrayInputStream(output)))
                .next().getFormatName().toLowerCase());
    }

    @Test
    void acceptsAndNormalizesJpeg() throws Exception {
        byte[] input = image("jpeg", 32, 24);
        byte[] output = CandidatePhotoValidator.validateAndNormalize(input);

        assertNotNull(ImageIO.read(new java.io.ByteArrayInputStream(output)));
    }

    @Test
    void rejectsNonImageAndTruncatedImage() {
        assertThrows(IllegalArgumentException.class,
                () -> CandidatePhotoValidator.validateAndNormalize("not an image".getBytes()));
        assertThrows(IllegalArgumentException.class,
                () -> CandidatePhotoValidator.validateAndNormalize(new byte[] {
                        (byte) 0xFF, (byte) 0xD8, (byte) 0xFF, 0x00, 0x01
                }));
    }

    @Test
    void rejectsOversizedInput() {
        byte[] oversized = new byte[(int) CandidatePhotoValidator.MAX_BYTES + 1];
        assertThrows(IllegalArgumentException.class,
                () -> CandidatePhotoValidator.validateAndNormalize(oversized));
    }

    @Test
    void rejectsExcessiveImageDimensions() throws Exception {
        byte[] oversizedImage = image("png", 6001, 1);
        IllegalArgumentException error = assertThrows(IllegalArgumentException.class,
                () -> CandidatePhotoValidator.validateAndNormalize(oversizedImage));
        assertTrue(error.getMessage().contains("dimensions"));
    }

    private static byte[] image(String format, int width, int height) throws Exception {
        BufferedImage image = new BufferedImage(width, height,
                "jpeg".equals(format) ? BufferedImage.TYPE_INT_RGB : BufferedImage.TYPE_INT_ARGB);
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        assertTrue(ImageIO.write(image, format, output));
        return output.toByteArray();
    }
}
