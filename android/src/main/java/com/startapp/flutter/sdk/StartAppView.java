package com.startapp.flutter.sdk;

import android.content.Context;
import android.util.TypedValue;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.platform.PlatformView;

public abstract class StartAppView implements PlatformView {
    private View view;

    public void createView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        this.view = onCreateView(context, id, creationParams);
    }

    @NonNull
    public abstract View onCreateView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams);

    @Override
    public View getView() {
        return view;
    }

    @Override
    public void dispose() {
        // none
    }

    public static int getInt(@Nullable Map<String, Object> creationParams, @NonNull String key, int defaultValue) {
        if (creationParams != null) {
            Object value = creationParams.get(key);
            if (value instanceof Number) {
                return ((Number) value).intValue();
            }
        }

        return defaultValue;
    }

    public static int dpToPx(@NonNull Context context, float dp) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, context.getResources().getDisplayMetrics());
    }
}
