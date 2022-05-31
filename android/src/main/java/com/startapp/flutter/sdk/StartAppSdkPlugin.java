package com.startapp.flutter.sdk;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;
import static com.startapp.flutter.sdk.BuildConfig.DEBUG;
import static com.startapp.flutter.sdk.StartAppFlutterBanner.TYPE_COVER;
import static com.startapp.flutter.sdk.StartAppFlutterBanner.TYPE_MREC;

import android.content.Context;
import android.graphics.Point;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.startapp.sdk.ads.banner.Banner;
import com.startapp.sdk.ads.banner.BannerListener;
import com.startapp.sdk.ads.banner.Cover;
import com.startapp.sdk.ads.banner.Mrec;
import com.startapp.sdk.ads.banner.bannerstandard.BannerStandard;
import com.startapp.sdk.ads.nativead.NativeAdDetails;
import com.startapp.sdk.ads.nativead.NativeAdPreferences;
import com.startapp.sdk.ads.nativead.StartAppNativeAd;
import com.startapp.sdk.adsbase.Ad;
import com.startapp.sdk.adsbase.SDKAdPreferences;
import com.startapp.sdk.adsbase.StartAppAd;
import com.startapp.sdk.adsbase.StartAppSDK;
import com.startapp.sdk.adsbase.adlisteners.AdDisplayListener;
import com.startapp.sdk.adsbase.adlisteners.AdEventListener;
import com.startapp.sdk.adsbase.adlisteners.VideoListener;
import com.startapp.sdk.adsbase.model.AdPreferences;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

@SuppressWarnings("deprecation")
@Keep
public class StartAppSdkPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String LOG_TAG = StartAppSdkPlugin.class.getSimpleName();

    private static final int METHOD_NOT_IMPLEMENTED = 0;
    private static final int METHOD_SUCCESS = 1;
    private static final int METHOD_ASYNC = 2;

    @Nullable
    private MethodChannel channel;

    @Nullable
    private Context context;

    @Nullable
    private Handler uiHandler;

    @NonNull
    private final StartAppSequence sequence = new StartAppSequence();

    @NonNull
    private final StartAppKeeper<BannerStandard> bannerAdKeeper = new StartAppKeeper<>(sequence);

    @NonNull
    private final StartAppKeeper<StartAppAd> fullScreenAdKeeper = new StartAppKeeper<>(sequence);

    @NonNull
    private final StartAppKeeper<NativeAdDetails> nativeAdKeeper = new StartAppKeeper<>(sequence);

    @NonNull
    public Handler getUiHandler() {
        Handler result = uiHandler;

        if (result == null) {
            result = new Handler(Looper.getMainLooper());

            uiHandler = result;
        }

        return result;
    }

    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        binding.getPlatformViewRegistry()
                .registerViewFactory("com.startapp.flutter.Banner",
                        new StartAppViewFactory<>(new StartAppViewFactory.FactoryMethod<StartAppView>() {
                            @NonNull
                            @Override
                            public StartAppView newInstance() {
                                return new StartAppFlutterBanner(bannerAdKeeper);
                            }
                        }));

        binding.getPlatformViewRegistry()
                .registerViewFactory("com.startapp.flutter.Native",
                        new StartAppViewFactory<>(new StartAppViewFactory.FactoryMethod<StartAppView>() {
                            @NonNull
                            @Override
                            public StartAppView newInstance() {
                                return new StartAppFlutterNative(nativeAdKeeper);
                            }
                        }));

        if (channel == null) {
            channel = new MethodChannel(binding.getBinaryMessenger(), "com.startapp.flutter");
            channel.setMethodCallHandler(this);
        }

        context = binding.getApplicationContext();

        StartAppSDK.addWrapper(context, "flutter", BuildConfig.VERSION_NAME);
    }

    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
    }

    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (DEBUG) {
            Log.v(LOG_TAG, "onMethodCall: " + call.method + ", args: " + call.arguments);
        }

        try {
            if (context != null) {
                Object[] returnValue = {null};
                int state = handleMethodCall(context, call.method, call.arguments, result, returnValue);

                if (state == METHOD_NOT_IMPLEMENTED) {
                    if (DEBUG) {
                        Log.v(LOG_TAG, "onMethodCall: notImplemented");
                    }

                    result.notImplemented();
                } else if (state == METHOD_SUCCESS) {
                    if (DEBUG) {
                        Log.v(LOG_TAG, "onMethodCall: success: " + returnValue[0]);
                    }

                    result.success(returnValue[0]);
                } else if (state == METHOD_ASYNC) {
                    if (DEBUG) {
                        Log.v(LOG_TAG, "onMethodCall: async");
                    }
                }
            } else {
                if (DEBUG) {
                    Log.e(LOG_TAG, "onMethodCall: context is null");
                }

                result.error(null, null, null);
            }
        } catch (Throwable ex) {
            if (DEBUG) {
                Log.w(LOG_TAG, "onMethodCall: error", ex);
            }

            result.error(ex.getClass().getName(), ex.getMessage(), null);
        }
    }

    @SuppressWarnings({"unchecked", "rawtypes"})
    private int handleMethodCall(@NonNull Context context, @NonNull String method, @Nullable Object arguments, @NonNull Result result, @NonNull Object[] returnValue) {
        switch (method) {
            case "getSdkVersion":
                returnValue[0] = StartAppSDK.getVersion();
                return METHOD_SUCCESS;

            case "setTestAdsEnabled":
                StartAppSDK.setTestAdsEnabled(Boolean.TRUE.equals(arguments));
                returnValue[0] = true;
                return METHOD_SUCCESS;

            case "disableSplash":
                StartAppAd.disableSplash();
                returnValue[0] = true;
                return METHOD_SUCCESS;

            case "loadBannerAd":
                loadBannerAd(context, (Map) arguments, new StartAppMethodResultWrapper(result));
                return METHOD_ASYNC;

            case "loadInterstitialAd":
                loadFullScreenAd(context, null, (Map) arguments, new StartAppMethodResultWrapper(result));
                return METHOD_ASYNC;

            case "showInterstitialAd":
                showFullScreenAd(context, false, (Map) arguments, result);
                return METHOD_ASYNC;

            case "loadRewardedVideoAd":
                loadFullScreenAd(context, StartAppAd.AdMode.REWARDED_VIDEO, (Map) arguments, new StartAppMethodResultWrapper(result));
                return METHOD_ASYNC;

            case "showRewardedVideoAd":
                showFullScreenAd(context, true, (Map) arguments, result);
                return METHOD_ASYNC;

            case "loadNativeAd":
                loadNativeAd(context, (Map) arguments, new StartAppMethodResultWrapper(result));
                return METHOD_ASYNC;

            default:
                return METHOD_NOT_IMPLEMENTED;
        }
    }

    private void notifyAdEvent(int adId, @NonNull String adEvent) {
        if (channel != null) {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("id", adId);
            arguments.put("event", adEvent);

            channel.invokeMethod("onAdEvent", arguments);
        }
    }

    private void loadBannerAd(@NonNull Context context, @Nullable Map<String, Object> arguments, @NonNull final StartAppMethodResultWrapper result) {
        if (DEBUG) {
            Log.v(LOG_TAG, "loadBannerAd");
        }

        final float density = context.getResources().getDisplayMetrics().density;

        AdPreferences adPreferences = new AdPreferences();

        fillAdPreferences(adPreferences, arguments);

        final Handler uiHandler = getUiHandler();

        final AtomicReference<BannerStandard> bannerRef = new AtomicReference<>();
        final AtomicReference<Point> sizeRef = new AtomicReference<>();
        final AtomicInteger adId = new AtomicInteger();

        BannerListener bannerListener = new BannerListener() {
            @Override
            public void onReceiveAd(View view) {
                if (DEBUG) {
                    Log.v(LOG_TAG, "loadBannerAd: onReceiveAd");
                }

                BannerStandard banner = bannerRef.get();
                if (banner == null) {
                    result.error("internal_plugin_error", "banner_is_null");
                    return;
                }

                Point size = sizeRef.get();
                if (size == null) {
                    result.error("internal_plugin_error", "banner_size_is_null");
                    return;
                }

                int id = bannerAdKeeper.add(banner);
                adId.set(id);

                final Map<String, Object> data = new HashMap<>();
                data.put("id", id);
                data.put("width", magicFlutterDp(size.x, density));
                data.put("height", magicFlutterDp(size.y, density));

                uiHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        result.success(data);
                    }
                });
            }

            @Override
            public void onFailedToReceiveAd(View view) {
                if (DEBUG) {
                    Log.v(LOG_TAG, "loadBannerAd: onFailedToReceiveAd");
                }

                final BannerStandard banner = bannerRef.get();

                uiHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        result.error("failed_to_receive_ad", banner != null ? banner.getErrorMessage() : null);
                    }
                });
            }

            @Override
            public void onImpression(View view) {
                notifyAdEvent(adId.get(), "adImpression");
            }

            @Override
            public void onClick(View view) {
                notifyAdEvent(adId.get(), "adClicked");
            }
        };

        if (arguments != null) {
            Object type = arguments.get("type");
            if (TYPE_MREC.equals(type)) {
                bannerRef.set(new Mrec(context, adPreferences, bannerListener));
                sizeRef.set(new Point(300, 250));
            } else if (TYPE_COVER.equals(type)) {
                bannerRef.set(new Cover(context, adPreferences, bannerListener));
                sizeRef.set(new Point(1200, 628));
            }
        }

        if (bannerRef.get() == null) {
            bannerRef.set(new Banner(context, adPreferences, bannerListener));
            sizeRef.set(new Point(320, 50));
        }

        BannerStandard banner = bannerRef.get();
        if (banner == null) {
            result.error("internal_plugin_error", "banner_not_created");
            return;
        }

        Point size = sizeRef.get();
        if (size == null) {
            result.error("internal_plugin_error", "size_not_created");
            return;
        }

        if (arguments != null) {
            Object desiredWidth = arguments.get("desiredWidth");
            if (desiredWidth instanceof Number) {
                if (size.x < ((Number) desiredWidth).intValue()) {
                    size.x = ((Number) desiredWidth).intValue();
                }
            }

            Object desiredHeight = arguments.get("desiredHeight");
            if (desiredHeight instanceof Number) {
                if (size.y < ((Number) desiredHeight).intValue()) {
                    size.y = ((Number) desiredHeight).intValue();
                }
            }
        }

        banner.setLayoutParams(new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        banner.loadAd(size.x, size.y);

        uiHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                result.error("timeout", null);
            }
        }, 3000);
    }

    private void loadFullScreenAd(@NonNull Context context, @Nullable StartAppAd.AdMode adMode, @Nullable Map<String, Object> arguments, @NonNull final StartAppMethodResultWrapper result) {
        if (DEBUG) {
            Log.v(LOG_TAG, "loadFullScreenAd");
        }

        AdPreferences adPreferences = new AdPreferences();
        fillAdPreferences(adPreferences, arguments);

        if (adMode == null) {
            adMode = getAdMode(arguments);
        }

        final Handler uiHandler = getUiHandler();
        final StartAppAd fullScreenAd = new StartAppAd(context);

        fullScreenAd.loadAd(adMode, adPreferences, new AdEventListener() {
            @Override
            public void onReceiveAd(@NonNull Ad ad) {
                if (DEBUG) {
                    Log.v(LOG_TAG, "loadFullScreenAd: onReceiveAd");
                }

                int id = fullScreenAdKeeper.add(fullScreenAd);

                final Map<String, Object> data = new HashMap<>();
                data.put("id", id);

                uiHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        result.success(data);
                    }
                });
            }

            @Override
            public void onFailedToReceiveAd(@Nullable final Ad ad) {
                if (DEBUG) {
                    Log.v(LOG_TAG, "loadFullScreenAd: onFailedToReceiveAd");
                }

                uiHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        result.error("failed_to_receive_ad", ad != null ? ad.getErrorMessage() : null);
                    }
                });
            }
        });

        uiHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                result.error("timeout", null);
            }
        }, 3000);
    }

    private void showFullScreenAd(
            @SuppressWarnings("unused") @NonNull Context context,
            boolean rewardedVideo,
            @Nullable Map<String, Object> arguments,
            @NonNull Result result
    ) {
        if (DEBUG) {
            Log.v(LOG_TAG, "showFullScreenAd");
        }

        if (arguments == null) {
            result.error("no_id", null, null);
            return;
        }

        Object idObj = arguments.get("id");
        if (!(idObj instanceof Integer)) {
            result.error("invalid_id", null, null);
            return;
        }

        final int id = (Integer) idObj;

        StartAppAd fullScreenAd = fullScreenAdKeeper.get(id);

        if (fullScreenAd == null) {
            result.error("ad_not_found", null, null);
            return;
        }

        if (rewardedVideo) {
            fullScreenAd.setVideoListener(new VideoListener() {
                @Override
                public void onVideoCompleted() {
                    notifyAdEvent(id, "videoCompleted");
                }
            });
        }

        boolean shown = fullScreenAd.showAd(new AdDisplayListener() {
            @Override
            public void adDisplayed(Ad ad) {
                notifyAdEvent(id, "adDisplayed");
            }

            @Override
            public void adNotDisplayed(Ad ad) {
                notifyAdEvent(id, "adNotDisplayed");

                fullScreenAdKeeper.remove(id);
            }

            @Override
            public void adClicked(Ad ad) {
                notifyAdEvent(id, "adClicked");
            }

            @Override
            public void adHidden(Ad ad) {
                notifyAdEvent(id, "adHidden");

                fullScreenAdKeeper.remove(id);
            }
        });

        result.success(shown);
    }

    private void loadNativeAd(@NonNull Context context, @Nullable Map<String, Object> arguments, @NonNull final StartAppMethodResultWrapper result) {
        if (DEBUG) {
            Log.v(LOG_TAG, "loadNativeAd");
        }

        NativeAdPreferences adPreferences = new NativeAdPreferences()
                .setAdsNumber(1)
                .setAutoBitmapDownload(false);

        fillAdPreferences(adPreferences, arguments);

        final Handler uiHandler = getUiHandler();

        final StartAppNativeAd nativeAd = new StartAppNativeAd(context);

        AdEventListener adEventListener = new AdEventListener() {
            @Override
            public void onReceiveAd(@NonNull Ad ad) {
                if (DEBUG) {
                    Log.v(LOG_TAG, "loadNativeAd: onReceiveAd");
                }

                ArrayList<NativeAdDetails> nativeAds = nativeAd.getNativeAds();
                if (nativeAds == null || nativeAds.size() < 1 || nativeAds.get(0) == null) {
                    uiHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            result.error("no_fill", null);
                        }
                    });
                } else {
                    NativeAdDetails details = nativeAds.get(0);
                    int id = nativeAdKeeper.add(details);

                    final Map<String, Object> data = new HashMap<>();
                    data.put("id", id);
                    putIfNotNull(data, "title", details.getTitle());
                    putIfNotNull(data, "description", details.getDescription());
                    putIfNotNull(data, "rating", details.getRating());
                    putIfNotNull(data, "installs", details.getInstalls());
                    putIfNotNull(data, "category", details.getCategory());
                    putIfNotNull(data, "campaign", details.getCampaignAction() != null ? details.getCampaignAction().name() : null);
                    putIfNotNull(data, "callToAction", details.getCallToAction());
                    putIfNotNull(data, "imageUrl", details.getImageUrl());
                    putIfNotNull(data, "secondaryImageUrl", details.getSecondaryImageUrl());

                    uiHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            result.success(data);
                        }
                    });
                }
            }

            @Override
            public void onFailedToReceiveAd(@Nullable final Ad ad) {
                if (DEBUG) {
                    Log.v(LOG_TAG, "loadNativeAd: onFailedToReceiveAd");
                }

                uiHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        result.error("failed_to_receive_ad", ad != null ? ad.getErrorMessage() : null);
                    }
                });
            }
        };

        boolean loading = false;

        try {
            // noinspection ConstantConditions
            loading = (Boolean) StartAppNativeAd.class
                    .getDeclaredMethod("loadAd", NativeAdPreferences.class, AdEventListener.class)
                    .invoke(nativeAd, adPreferences, adEventListener);
        } catch (ReflectiveOperationException ex) {
            if (DEBUG) {
                Log.w(LOG_TAG, ex);
            }

            result.error("internal_sdk_error", ex.toString());
        }

        if (DEBUG) {
            Log.v(LOG_TAG, "loadNativeAd: loading: " + loading);
        }

        if (loading) {
            uiHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    result.error("timeout", null);
                }
            }, 3000);
        } else {
            result.error("loading_error", nativeAd.getErrorMessage());
        }
    }

    private void fillAdPreferences(@NonNull AdPreferences prefs, @Nullable Map<String, Object> args) {
        if (args != null) {
            Object adTag = args.get("adTag");
            if (adTag instanceof String) {
                prefs.setAdTag((String) adTag);
            }

            Object keywords = args.get("keywords");
            if (keywords instanceof String) {
                prefs.setKeywords((String) keywords);
            }

            Object gender = args.get("gender");
            if (gender instanceof String) {
                prefs.setGender(SDKAdPreferences.Gender.parseString((String) gender));
            }

            Object age = args.get("age");
            if (age instanceof Number) {
                prefs.setAge(((Number) age).intValue());
            } else if (age instanceof String) {
                prefs.setAge((String) age);
            }

            Object videoMuted = args.get("videoMuted");
            if (videoMuted instanceof Boolean) {
                if ((Boolean) videoMuted) {
                    prefs.muteVideo();
                }
            } else if (videoMuted instanceof String) {
                if (Boolean.parseBoolean((String) videoMuted)) {
                    prefs.muteVideo();
                }
            }

            Object hardwareAccelerated = args.get("hardwareAccelerated");
            if (hardwareAccelerated instanceof Boolean) {
                prefs.setHardwareAccelerated((Boolean) hardwareAccelerated);
            } else if (hardwareAccelerated instanceof String) {
                prefs.setHardwareAccelerated(Boolean.parseBoolean((String) hardwareAccelerated));
            }

            Object categories = args.get("categories");
            if (categories instanceof Iterable) {
                // noinspection RedundantSuppression,rawtypes
                for (Object value : (Iterable) categories) {
                    if (value instanceof String) {
                        prefs.addCategory((String) value);
                    }
                }
            }

            Object categoriesExclude = args.get("categoriesExclude");
            if (categoriesExclude instanceof Iterable) {
                // noinspection RedundantSuppression,rawtypes
                for (Object value : (Iterable) categoriesExclude) {
                    if (value instanceof String) {
                        prefs.addCategoryExclude((String) value);
                    }
                }
            }

            Object adType = args.get("adType");
            if (adType instanceof String) {
                try {
                    prefs.setType(Ad.AdType.valueOf(((String) adType).toUpperCase(Locale.ENGLISH)));
                } catch (RuntimeException ex) {
                    if (DEBUG) {
                        Log.w(LOG_TAG, ex);
                    }
                }
            }

            Object minCPM = args.get("minCPM");
            if (minCPM instanceof Number) {
                try {
                    prefs.setMinCpm(((Number) minCPM).doubleValue());
                } catch (RuntimeException ex) {
                    if (DEBUG) {
                        Log.w(LOG_TAG, ex);
                    }
                }
            }
        }
    }

    @NonNull
    private StartAppAd.AdMode getAdMode(@Nullable Map<String, Object> args) {
        if (args != null) {
            Object modeObj = args.get("mode");
            if (modeObj instanceof Integer) {
                int mode = (Integer) modeObj;

                if (mode == 1) {
                    return StartAppAd.AdMode.VIDEO;
                }
            }
        }

        return StartAppAd.AdMode.AUTOMATIC;
    }

    private static float magicFlutterDp(float dp, float density) {
        return (float) (Math.ceil(Math.ceil(dp * density) * 10 / density) / 10);
    }

    static <K, V> void putIfNotNull(@NonNull Map<K, V> map, @NonNull K key, @Nullable V value) {
        if (value != null) {
            map.put(key, value);
        }
    }
}
