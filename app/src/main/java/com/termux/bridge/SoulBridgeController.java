package com.termux.bridge;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.termux.shared.logger.Logger;
import com.termux.terminal.TerminalSession;

import io.flutter.plugin.common.BinaryMessenger;

/**
 * Controls the SoulBridgeApi (Flutter API called from host side).
 * Handles debounced terminal output streaming to Flutter at max 10 updates/sec.
 */
public class SoulBridgeController {

    private static final String LOG_TAG = "SoulBridgeController";
    private static final long DEBOUNCE_DELAY_MS = 100; // 100ms = max 10 updates/sec

    private TerminalBridgeApi.SoulBridgeApi mSoulBridge;
    private final Handler mDebounceHandler = new Handler(Looper.getMainLooper());
    private Runnable mPendingUpdate;

    /**
     * Initialize the SoulBridge with the Flutter engine's binary messenger.
     */
    public void setup(@NonNull BinaryMessenger binaryMessenger) {
        mSoulBridge = new TerminalBridgeApi.SoulBridgeApi(binaryMessenger);
        Logger.logDebug(LOG_TAG, "SoulBridge connected to Flutter");
    }

    /**
     * Called when terminal text changes. Debounces output to max 10/sec.
     * Call this from TermuxTerminalSessionClient.onTextChanged().
     */
    public void onTerminalTextChanged(@Nullable TerminalSession session) {
        if (mSoulBridge == null || session == null || session.getEmulator() == null) return;

        // Cancel any pending debounced update
        if (mPendingUpdate != null) {
            mDebounceHandler.removeCallbacks(mPendingUpdate);
        }

        mPendingUpdate = () -> {
            try {
                String output = session.getEmulator().getScreen().getTranscriptText();
                // Send last 50 lines to avoid sending massive transcript
                String[] lines = output.split("\n");
                int startIndex = Math.max(0, lines.length - 50);
                StringBuilder lastLines = new StringBuilder();
                for (int i = startIndex; i < lines.length; i++) {
                    if (i > startIndex) lastLines.append("\n");
                    lastLines.append(lines[i]);
                }
                mSoulBridge.onTerminalOutput(lastLines.toString(), reply -> {});
            } catch (Exception e) {
                Logger.logError(LOG_TAG, "Failed to stream terminal output: " + e.getMessage());
            }
        };

        mDebounceHandler.postDelayed(mPendingUpdate, DEBOUNCE_DELAY_MS);
    }

    /**
     * Notify Flutter of a session change.
     */
    public void onSessionChanged(int sessionId, @NonNull String sessionName, boolean isRunning) {
        if (mSoulBridge == null) return;

        TerminalBridgeApi.SessionInfo info = new TerminalBridgeApi.SessionInfo.Builder()
            .setId((long) sessionId)
            .setName(sessionName)
            .setIsRunning(isRunning)
            .build();

        mSoulBridge.onSessionChanged(info, reply -> {});
    }

    /**
     * Notify Flutter that a command finished (OSC 133;D received).
     * @param sessionId the session index, resolved by TermuxActivity
     */
    public void onCommandFinished(long sessionId) {
        if (mSoulBridge == null) return;
        new Handler(Looper.getMainLooper()).post(() ->
            mSoulBridge.onCommandCompleted(sessionId, reply -> {})
        );
    }

    /**
     * Clean up resources.
     */
    public void teardown() {
        if (mPendingUpdate != null) {
            mDebounceHandler.removeCallbacks(mPendingUpdate);
        }
        mSoulBridge = null;
    }
}
