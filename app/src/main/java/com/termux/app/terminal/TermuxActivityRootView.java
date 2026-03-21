package com.termux.app.terminal;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowInsets;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.core.view.WindowInsetsCompat;

import com.termux.app.TermuxActivity;

/**
 * Legacy root view class — kept for compilation compatibility only.
 * The bottom-space-view IME workaround has been replaced by the bottom-sheet layout
 * using WindowInsetsCompat IME handling (added in Plan 07-01).
 * This class is no longer instantiated or referenced by TermuxActivity.
 */
public class TermuxActivityRootView extends LinearLayout implements ViewTreeObserver.OnGlobalLayoutListener {

    public TermuxActivity mActivity;
    public Integer marginBottom;

    private static int mStatusBarHeight;

    public TermuxActivityRootView(Context context) {
        super(context);
    }

    public TermuxActivityRootView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public TermuxActivityRootView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setActivity(TermuxActivity activity) {
        mActivity = activity;
    }

    public void setIsRootViewLoggingEnabled(boolean value) {
        // No-op: logging removed with the rest of the old IME workaround.
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        if (marginBottom != null) {
            ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) getLayoutParams();
            params.setMargins(0, 0, 0, marginBottom);
            setLayoutParams(params);
            marginBottom = null;
            requestLayout();
        }
    }

    @Override
    public void onGlobalLayout() {
        // Stubbed: TermuxActivityRootView is no longer used with the bottom-sheet layout.
        // IME handling is done via WindowInsetsCompat on the sheet container in TermuxActivity.
    }

    public static class WindowInsetsListener implements android.view.View.OnApplyWindowInsetsListener {
        @Override
        public WindowInsets onApplyWindowInsets(android.view.View v, WindowInsets insets) {
            mStatusBarHeight = WindowInsetsCompat.toWindowInsetsCompat(insets).getInsets(WindowInsetsCompat.Type.statusBars()).top;
            return v.onApplyWindowInsets(insets);
        }
    }

}
