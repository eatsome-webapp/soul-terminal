package com.termux.app.terminal;

import android.app.AlertDialog;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.termux.app.TermuxActivity;
import com.termux.shared.logger.Logger;
import com.termux.terminal.TerminalSession;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Detects y/n prompts in terminal output and shows a native AlertDialog.
 * Uses debounce to avoid triggering on partially rendered lines.
 */
public class PromptInterceptor {

    private static final String LOG_TAG = "PromptInterceptor";
    private static final long DEBOUNCE_DELAY_MS = 200;

    private static final Pattern YN_PROMPT_PATTERN = Pattern.compile(
        ".*\\s(\\[y/N\\]|\\[Y/n\\]|\\[yes/no\\]|\\(yes/no\\)|\\[Y/N\\])\\s*$",
        Pattern.CASE_INSENSITIVE
    );

    private static final Pattern ANSI_ESCAPE_PATTERN = Pattern.compile(
        "\\x1B\\[[0-9;]*[a-zA-Z]"
    );

    private final TermuxActivity mActivity;
    private final Handler mDebounceHandler = new Handler(Looper.getMainLooper());
    private Runnable mPendingCheck;
    private boolean mPromptDialogShowing = false;

    public PromptInterceptor(@NonNull TermuxActivity activity) {
        mActivity = activity;
    }

    /**
     * Check the current session's last line for a y/n prompt.
     * Called from onTextChanged() with debounce.
     */
    public void checkForPrompt(@NonNull TerminalSession session) {
        if (mPromptDialogShowing) return;

        // Only intercept when sheet is visible (not hidden)
        BottomSheetBehavior<?> sheetBehavior = mActivity.getBottomSheetBehavior();
        if (sheetBehavior != null && sheetBehavior.getState() == BottomSheetBehavior.STATE_HIDDEN) {
            return;
        }

        if (mPendingCheck != null) {
            mDebounceHandler.removeCallbacks(mPendingCheck);
        }

        mPendingCheck = () -> {
            try {
                if (session.getEmulator() == null) return;
                String transcript = session.getEmulator().getScreen().getTranscriptText();
                if (transcript == null || transcript.isEmpty()) return;

                // Get last non-empty line
                String[] lines = transcript.split("\n");
                String lastLine = null;
                for (int i = lines.length - 1; i >= 0; i--) {
                    String trimmed = lines[i].trim();
                    if (!trimmed.isEmpty()) {
                        lastLine = trimmed;
                        break;
                    }
                }
                if (lastLine == null) return;

                // Strip ANSI escape codes
                String cleanLine = ANSI_ESCAPE_PATTERN.matcher(lastLine).replaceAll("");

                Matcher matcher = YN_PROMPT_PATTERN.matcher(cleanLine);
                if (matcher.matches()) {
                    // Extract prompt text (everything before the [y/N] token)
                    String promptText = cleanLine
                        .replaceAll("\\s*([\\[(](?:y/N|Y/n|yes/no|Y/N)[\\])])\\s*$", "")
                        .trim();
                    if (promptText.isEmpty()) {
                        promptText = cleanLine;
                    }
                    showPromptDialog(session, promptText);
                }
            } catch (Exception e) {
                Logger.logError(LOG_TAG, "Error checking for prompt: " + e.getMessage());
            }
        };

        mDebounceHandler.postDelayed(mPendingCheck, DEBOUNCE_DELAY_MS);
    }

    private void showPromptDialog(@NonNull TerminalSession session, @NonNull String promptText) {
        if (mPromptDialogShowing) return;
        mPromptDialogShowing = true;

        new Handler(Looper.getMainLooper()).post(() -> {
            try {
                // TalkBack announcement for y/n prompt dialog
                mActivity.getTerminalView().announceForAccessibility("Bevestiging vereist: " + promptText);

                new AlertDialog.Builder(mActivity)
                    .setTitle("Bevestiging vereist")
                    .setMessage(promptText)
                    .setPositiveButton("Ja", (dialog, which) -> {
                        session.write("y\n");
                        mPromptDialogShowing = false;
                        Logger.logDebug(LOG_TAG, "User confirmed prompt with 'y'");
                    })
                    .setNegativeButton("Nee", (dialog, which) -> {
                        session.write("n\n");
                        mPromptDialogShowing = false;
                        Logger.logDebug(LOG_TAG, "User declined prompt with 'n'");
                    })
                    .setCancelable(false)
                    .show();
            } catch (Exception e) {
                mPromptDialogShowing = false;
                Logger.logError(LOG_TAG, "Failed to show prompt dialog: " + e.getMessage());
            }
        });
    }

    /**
     * Clean up pending callbacks.
     */
    public void teardown() {
        if (mPendingCheck != null) {
            mDebounceHandler.removeCallbacks(mPendingCheck);
        }
        mPromptDialogShowing = false;
    }
}
