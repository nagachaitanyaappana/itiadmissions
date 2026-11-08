package com.server.backend.service.Student;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Iterator;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.ImageOutputStream;

/**
 * Validates and canonicalizes candidate photographs before they are persisted.
 * Only fully decodable PNG/JPEG images are accepted. Re-encoding strips embedded
 * metadata and trailing/polyglot payloads rather than storing attacker-controlled
 * container bytes verbatim.
 */
public final class CandidatePhotoValidator {
    public static final long MAX_BYTES = 5L * 1024L * 1024L;
    private static final int MAX_DIMENSION = 6000;
    private static final long MAX_PIXELS = 12_000_000L;

    private CandidatePhotoValidator() {
    }

    public static byte[] validateAndNormalize(byte[] input) {
        if (input == null || input.length == 0) {
            throw new IllegalArgumentException("Please select a photograph to upload");
        }
        if (input.length > MAX_BYTES) {
            throw new IllegalArgumentException("Photograph must not exceed 5 MB");
        }

        try (ImageInputStream imageInput = ImageIO.createImageInputStream(new ByteArrayInputStream(input))) {
            if (imageInput == null) {
                throw invalidImage();
            }
            Iterator<ImageReader> readers = ImageIO.getImageReaders(imageInput);
            if (!readers.hasNext()) {
                throw invalidImage();
            }

            ImageReader reader = readers.next();
            try {
                reader.setInput(imageInput, true, true);
                String format = reader.getFormatName();
                boolean png = "png".equalsIgnoreCase(format);
                boolean jpeg = "jpeg".equalsIgnoreCase(format) || "jpg".equalsIgnoreCase(format);
                if (!png && !jpeg) {
                    throw invalidImage();
                }

                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                if (width <= 0 || height <= 0 || width > MAX_DIMENSION || height > MAX_DIMENSION
                        || (long) width * height > MAX_PIXELS) {
                    throw new IllegalArgumentException(
                            "Photograph dimensions must not exceed 6000 x 6000 pixels or 12 megapixels");
                }

                BufferedImage decoded = reader.read(0);
                if (decoded == null || decoded.getWidth() != width || decoded.getHeight() != height) {
                    throw invalidImage();
                }

                String outputFormat = png ? "png" : "jpeg";
                BufferedImage normalized = decoded;
                if (jpeg && decoded.getType() != BufferedImage.TYPE_INT_RGB) {
                    normalized = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
                    java.awt.Graphics2D graphics = normalized.createGraphics();
                    try {
                        graphics.setColor(java.awt.Color.WHITE);
                        graphics.fillRect(0, 0, width, height);
                        graphics.drawImage(decoded, 0, 0, null);
                    } finally {
                        graphics.dispose();
                    }
                }

                Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName(outputFormat);
                if (!writers.hasNext()) {
                    throw new IllegalStateException("Image encoder is unavailable");
                }
                ImageWriter writer = writers.next();
                try (ByteArrayOutputStream bytes = new ByteArrayOutputStream();
                        ImageOutputStream imageOutput = ImageIO.createImageOutputStream(bytes)) {
                    if (imageOutput == null) {
                        throw new IllegalStateException("Could not initialize image encoder");
                    }
                    writer.setOutput(imageOutput);
                    writer.write(normalized);
                    imageOutput.flush();
                    byte[] result = bytes.toByteArray();
                    if (result.length == 0 || result.length > MAX_BYTES) {
                        throw new IllegalArgumentException("Processed photograph must not exceed 5 MB");
                    }
                    return result;
                } finally {
                    writer.dispose();
                }
            } finally {
                reader.dispose();
            }
        } catch (IllegalArgumentException | IllegalStateException ex) {
            throw ex;
        } catch (IOException | RuntimeException ex) {
            throw invalidImage();
        }
    }

    private static IllegalArgumentException invalidImage() {
        return new IllegalArgumentException("Photograph must be a valid, decodable PNG or JPEG image");
    }
}
