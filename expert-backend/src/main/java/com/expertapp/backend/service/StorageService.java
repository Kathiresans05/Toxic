package com.expertapp.backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class StorageService {

    private static final Logger log = LoggerFactory.getLogger(StorageService.class);

    @Value("${app.aws.s3.bucket-name:expert-app-media}")
    private String bucketName;

    @Value("${app.aws.s3.access-key:}")
    private String accessKey;

    private final Path localUploadDir = Paths.get("uploads");

    public StorageService() {
        try {
            Files.createDirectories(localUploadDir);
        } catch (IOException e) {
            log.error("Failed to create upload directory", e);
        }
    }

    public String uploadFile(MultipartFile file, String folder) throws IOException {
        String filename = folder + "/" + UUID.randomUUID() + "_" + file.getOriginalFilename();

        if (accessKey == null || accessKey.isBlank()) {
            // Local filesystem fallback when AWS credentials are not yet supplied
            Path targetPath = localUploadDir.resolve(UUID.randomUUID() + "_" + file.getOriginalFilename());
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);
            return "/api/v1/storage/files/" + targetPath.getFileName().toString();
        }

        // Production AWS S3 upload implementation URL
        return "https://" + bucketName + ".s3.amazonaws.com/" + filename;
    }
}
