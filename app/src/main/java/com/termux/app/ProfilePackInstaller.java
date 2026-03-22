package com.termux.app;

import android.system.Os;

import androidx.core.util.Pair;

import com.termux.shared.logger.Logger;
import com.termux.shared.termux.TermuxConstants;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import static com.termux.shared.termux.TermuxConstants.TERMUX_PREFIX_DIR_PATH;

/**
 * Extracts profile pack zip files over an existing $PREFIX directory.
 * Profile packs are additive — they layer packages on top of the base bootstrap.
 * Format is identical to bootstrap: zip with SYMLINKS.txt + files.
 */
public final class ProfilePackInstaller {

    private static final String LOG_TAG = "ProfilePackInstaller";

    /**
     * Extract a profile pack zip over the existing $PREFIX.
     *
     * @param zipFilePath absolute path to the downloaded zip file
     * @param profileId   profile identifier (e.g. "claude-code") for version marker
     * @param version     version string to write as marker
     * @return null on success, error message on failure
     */
    public static String extractProfilePack(String zipFilePath, String profileId, String version) {
        try {
            File zipFile = new File(zipFilePath);
            if (!zipFile.exists()) {
                return "Profile pack zip not found: " + zipFilePath;
            }

            // Write install-in-progress marker (for crash recovery)
            File progressMarker = new File(TERMUX_PREFIX_DIR_PATH, ".soul-profile-installing");
            writeMarkerFile(progressMarker, profileId);

            Logger.logInfo(LOG_TAG, "Extracting profile pack '" + profileId + "' from " + zipFilePath);

            final byte[] buffer = new byte[8096];
            final List<Pair<String, String>> symlinks = new ArrayList<>(50);
            int fileCount = 0;

            try (ZipInputStream zipInput = new ZipInputStream(new FileInputStream(zipFile))) {
                ZipEntry zipEntry;
                while ((zipEntry = zipInput.getNextEntry()) != null) {
                    if (zipEntry.getName().equals("SYMLINKS.txt")) {
                        BufferedReader symlinksReader = new BufferedReader(new InputStreamReader(zipInput));
                        String line;
                        while ((line = symlinksReader.readLine()) != null) {
                            String[] parts = line.split("←");
                            if (parts.length != 2)
                                throw new RuntimeException("Malformed symlink line: " + line);
                            String oldPath = parts[0];
                            String newPath = TERMUX_PREFIX_DIR_PATH + "/" + parts[1];
                            symlinks.add(Pair.create(oldPath, newPath));

                            File parentDir = new File(newPath).getParentFile();
                            if (parentDir != null && !parentDir.exists()) {
                                parentDir.mkdirs();
                            }
                        }
                    } else {
                        String zipEntryName = zipEntry.getName();
                        File targetFile = new File(TERMUX_PREFIX_DIR_PATH, zipEntryName);
                        boolean isDirectory = zipEntry.isDirectory();

                        File parentDir = isDirectory ? targetFile : targetFile.getParentFile();
                        if (parentDir != null && !parentDir.exists()) {
                            parentDir.mkdirs();
                        }

                        if (!isDirectory) {
                            try (FileOutputStream outStream = new FileOutputStream(targetFile)) {
                                int readBytes;
                                while ((readBytes = zipInput.read(buffer)) != -1)
                                    outStream.write(buffer, 0, readBytes);
                            }
                            if (zipEntryName.startsWith("bin/") || zipEntryName.startsWith("libexec") ||
                                zipEntryName.startsWith("lib/apt/apt-helper") || zipEntryName.startsWith("lib/apt/methods")) {
                                //noinspection OctalInteger
                                Os.chmod(targetFile.getAbsolutePath(), 0700);
                            }
                            fileCount++;
                        }
                    }
                }
            }

            // Create symlinks
            for (Pair<String, String> symlink : symlinks) {
                File symlinkFile = new File(symlink.second);
                if (symlinkFile.exists()) {
                    symlinkFile.delete();
                }
                Os.symlink(symlink.first, symlink.second);
            }

            Logger.logInfo(LOG_TAG, "Extracted " + fileCount + " files and " + symlinks.size() + " symlinks for profile '" + profileId + "'");

            // Write version marker
            File versionMarker = new File(TERMUX_PREFIX_DIR_PATH, ".soul-profile-" + profileId);
            writeMarkerFile(versionMarker, version);

            // Remove in-progress marker
            progressMarker.delete();

            // Clean up downloaded zip
            zipFile.delete();

            return null; // success
        } catch (Exception e) {
            String error = "Failed to extract profile pack '" + profileId + "': " + e.getMessage();
            Logger.logStackTraceWithMessage(LOG_TAG, error, e);
            return error;
        }
    }

    /**
     * Verify SHA-256 checksum of a file.
     *
     * @param filePath     absolute path to the file
     * @param expectedHash expected lowercase hex SHA-256 hash
     * @return true if hash matches
     */
    public static boolean verifySha256(String filePath, String expectedHash) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] buffer = new byte[8096];
            try (FileInputStream fis = new FileInputStream(filePath)) {
                int readBytes;
                while ((readBytes = fis.read(buffer)) != -1) {
                    digest.update(buffer, 0, readBytes);
                }
            }
            byte[] hashBytes = digest.digest();
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            boolean match = hexString.toString().equalsIgnoreCase(expectedHash);
            if (!match) {
                Logger.logError(LOG_TAG, "SHA-256 mismatch for " + filePath +
                    ": expected " + expectedHash + ", got " + hexString);
            }
            return match;
        } catch (Exception e) {
            Logger.logStackTraceWithMessage(LOG_TAG, "SHA-256 verification failed for " + filePath, e);
            return false;
        }
    }

    /**
     * Get installed profile pack version.
     *
     * @param profileId profile identifier
     * @return version string or null if not installed
     */
    public static String getInstalledProfileVersion(String profileId) {
        File marker = new File(TERMUX_PREFIX_DIR_PATH, ".soul-profile-" + profileId);
        if (!marker.exists()) return null;
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(marker)))) {
            return reader.readLine();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Check if a profile pack installation was interrupted (crash recovery).
     *
     * @return profile ID that was being installed, or null
     */
    public static String getInterruptedInstallation() {
        File marker = new File(TERMUX_PREFIX_DIR_PATH, ".soul-profile-installing");
        if (!marker.exists()) return null;
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(marker)))) {
            return reader.readLine();
        } catch (Exception e) {
            return null;
        }
    }

    private static void writeMarkerFile(File file, String content) {
        try (FileOutputStream fos = new FileOutputStream(file)) {
            fos.write(content.getBytes());
            fos.write('\n');
        } catch (Exception e) {
            Logger.logError(LOG_TAG, "Failed to write marker file: " + file.getAbsolutePath());
        }
    }
}
