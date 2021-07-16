package com.startapp.flutter.sdk;

import android.content.ComponentName;
import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.pm.PackageManager;
import android.content.pm.ProviderInfo;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.startapp.sdk.adsbase.StartAppAd;

import static com.startapp.flutter.sdk.BuildConfig.DEBUG;

public class StartAppFlutterHelper extends ContentProvider {
    private static final String LOG_TAG = StartAppFlutterHelper.class.getSimpleName();

    @Override
    public boolean onCreate() {
        try {
            ProviderInfo info = getContext().getPackageManager().getProviderInfo(
                    new ComponentName(getContext(), StartAppFlutterHelper.class),
                    PackageManager.GET_META_DATA
            );

            if (info != null && info.metaData != null) {
                Object splashAdsEnabled = info.metaData.get("com.startapp.sdk.SPLASH_ADS_ENABLED");
                if (Boolean.FALSE.equals(splashAdsEnabled)) {
                    StartAppAd.disableSplash();
                }
            }
        } catch (Throwable ex) {
            if (DEBUG) {
                Log.w(LOG_TAG, ex);
            }
        }

        return false;
    }

    @Nullable
    @Override
    public Cursor query(@NonNull Uri uri, @Nullable String[] projection, @Nullable String selection, @Nullable String[] selectionArgs, @Nullable String sortOrder) {
        return null;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
        return null;
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
        return null;
    }

    @Override
    public int delete(@NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection, @Nullable String[] selectionArgs) {
        return 0;
    }
}
