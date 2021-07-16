package com.startapp.flutter.sdk;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static com.startapp.flutter.sdk.BuildConfig.DEBUG;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.startapp.sdk.ads.banner.bannerstandard.BannerStandard;

import java.util.Map;

public class StartAppFlutterBanner extends StartAppView {
    private static final String LOG_TAG = StartAppFlutterBanner.class.getSimpleName();

    @NonNull
    @SuppressWarnings("unused")
    public static final Integer TYPE_BANNER = 0;

    @NonNull
    public static final Integer TYPE_MREC = 1;

    @NonNull
    public static final Integer TYPE_COVER = 2;

    @NonNull
    private final StartAppKeeper<BannerStandard> bannerAdKeeper;

    public StartAppFlutterBanner(@NonNull StartAppKeeper<BannerStandard> bannerAdKeeper) {
        this.bannerAdKeeper = bannerAdKeeper;
    }

    @NonNull
    public View onCreateView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        if (DEBUG) {
            Log.v(LOG_TAG, "onCreateView: " + id + ", " + creationParams);
        }

        BannerStandard banner;
        String error;

        int adId = getInt(creationParams, "adId", 0);
        if (adId <= 0) {
            banner = null;
            error = "no_ad_id";
        } else {
            banner = bannerAdKeeper.get(adId);
            if (banner == null) {
                error = "no_ad_instance";
            } else {
                error = null;
            }
        }

        if (banner == null) {
            View view = new View(context);
            view.setLayoutParams(new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT));
            view.setBackground(new StartAppErrorDrawable(context.getResources(), "Error: " + error));
            return view;
        }

        return banner;
    }
}
