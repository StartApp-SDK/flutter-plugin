package com.startapp.flutter.sdk;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static com.startapp.flutter.sdk.BuildConfig.DEBUG;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.startapp.sdk.ads.nativead.NativeAdDetails;

import java.util.Map;

public class StartAppFlutterNative extends StartAppView {
    private static final String LOG_TAG = StartAppFlutterNative.class.getSimpleName();

    @NonNull
    private final StartAppKeeper<NativeAdDetails> nativeAdKeeper;

    public StartAppFlutterNative(@NonNull StartAppKeeper<NativeAdDetails> nativeAdKeeper) {
        this.nativeAdKeeper = nativeAdKeeper;
    }

    @NonNull
    public View onCreateView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        if (DEBUG) {
            Log.v(LOG_TAG, "onCreateView: " + id + ", " + creationParams);
        }

        int width = MATCH_PARENT;
        int height = MATCH_PARENT;

        if (creationParams != null) {
            Object w = creationParams.get("width");
            if (w instanceof Number) {
                width = dpToPx(context, ((Number) w).floatValue());
            }

            Object h = creationParams.get("height");
            if (h instanceof Number) {
                height = dpToPx(context, ((Number) h).floatValue());
            }
        }

        View view = new View(context);
        view.setLayoutParams(new ViewGroup.LayoutParams(width, height));

        final String error;

        int adId = getInt(creationParams, "adId", 0);
        if (adId <= 0) {
            error = "no_ad_id";
        } else {
            NativeAdDetails nativeAd = nativeAdKeeper.get(adId);
            if (nativeAd == null) {
                error = "no_ad_instance";
            } else {
                nativeAd.registerViewForInteraction(view);
                error = null;
            }
        }

        if (error != null) {
            view.setBackground(new StartAppErrorDrawable(context.getResources(), "Error: " + error));
        }

        return view;
    }
}
