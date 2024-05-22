# Start.io (StartApp) SDK

A Flutter plugin that uses native platform views to show ads from Start.io network.

[Android Demo](https://i.imgur.com/mvEHfvs.mp4)

[iOS Demo](https://i.imgur.com/WgjNWsP.mp4)

## Supported formats

- Banner
- Interstitial
- Rewarded Video
- Native

## Supported platforms

- Android
- iOS

## Installation

- Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  startapp_sdk: '<LATEST_VERSION>'
```

- Install package from the command line:

```sh
flutter pub get
```

### Android specific setup

**Mandatory**:

Add your App ID to your app's `AndroidManifest.xml` file by adding the `<meta-data>` tag shown below.
You can find your App ID on the Start.io Portal. For `android:value` insert your App ID in quotes,
as shown below.

```xml
<!-- TODO replace YOUR_APP_ID with actual value -->
<meta-data
    android:name="com.startapp.sdk.APPLICATION_ID"
    android:value="YOUR_APP_ID" />
```

**Optional**:

Return Ads are enabled by default. If you want to disable it, add another `<meta-data>` tag
into `AndroidManifest.xml` file.

```xml
<!-- TODO Return Ad controlled by the android:value below -->
<meta-data
    android:name="com.startapp.sdk.RETURN_ADS_ENABLED"
    android:value="false" />
```

Splash Ads are enabled by default. If you want to disable it, add `<provider>` tag into
`AndroidManifest.xml` file with another `<meta-data>` tag nested in that provider as shown below.

```xml
<!-- TODO Splash Ad controlled by the android:value below -->
<provider
    android:authorities="com.startapp.flutter.sdk.${applicationId}"
    android:name="com.startapp.flutter.sdk.StartAppFlutterHelper"
    android:exported="false">
    <meta-data
        android:name="com.startapp.sdk.SPLASH_ADS_ENABLED"
        android:value="false" />
</provider>
```

### iOS specific setup

**Mandatory**:

Add your App ID to your app's `Info.plist` for key `com.startapp.sdk.APPLICATION_ID`
You can find your App ID on the Start.io Portal.

```xml
<!-- TODO replace YOUR_APP_ID with actual value -->
    <key>com.startapp.sdk.APPLICATION_ID</key>
    <string>YOUR_APP_ID</string>
```

**Optional**:

Return Ads are enabled by default. If you want to disable it, set `NO` for `com.startapp.sdk.RETURN_ADS_ENABLED` in your`Info.plist`.

```xml
    <key>com.startapp.sdk.RETURN_ADS_ENABLED</key>
    <false/>
```

Splash Ads are disabled by default. If you want to enable it, set `YES` for `com.startapp.sdk.SPLASH_ADS_ENABLED` key in your`Info.plist`.

```xml
    <key>com.startapp.sdk.SPLASH_ADS_ENABLED</key>
    <true/>
```

## Usage

### Plugin initialization

Get an instance of `StartAppSdk` by calling it's default constructor.
It's safe to call this constructor multiple times - you'll get the same singleton instance.

```dart
class _MyAppState extends State<MyApp> {
  var startAppSdk = StartAppSdk();
}
```

### Test mode

Always use test mode during app development, but don't forget to disable it before production.

```dart
class _MyAppState extends State<MyApp> {
  var startAppSdk = StartAppSdk();

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(true);
  }
}
```

### Banner, Mrec, Cover

Each instance of `StartAppBannerAd` is linked to an underlying native view. It's refreshing
automatically, so you must load it only once and keep an instance of `StartAppBannerAd`.
Creating multiple banner instances is not prohibited, but this can affect performance of your app.

```dart
class _MyAppState extends State<MyApp> {
  var startAppSdk = StartAppSdk();

  StartAppBannerAd? bannerAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(true);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [bannerAd != null ? StartAppBanner(bannerAd!) : Container()],
      ),
    );
  }
}
```

### Interstitial

In opposite to banners, each instance of `StartAppInterstitialAd` can be displayed only once.
You have to load new instance in order to shown an interstitial ad another time.
You must assign `null` to the corresponding field after the ad was shown.

```dart
class _MyAppState extends State<MyApp> {
  var startAppSdk = StartAppSdk();

  StartAppInterstitialAd? interstitialAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(true);

    loadInterstitialAd();
  }

  void loadInterstitialAd() {
    startAppSdk.loadInterstitialAd().then((interstitialAd) {
      setState(() {
        this.interstitialAd = interstitialAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Interstitial ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Interstitial ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (interstitialAd != null) {
            interstitialAd!.show().then((shown) {
              if (shown) {
                setState(() {
                  // NOTE interstitial ad can be shown only once
                  this.interstitialAd = null;

                  // NOTE load again
                  loadInterstitialAd();
                });
              }

              return null;
            }).onError((error, stackTrace) {
              debugPrint("Error showing Interstitial ad: $error");
            });
          }
        },
        child: Text('Show Interstitial'),
      ),
    );
  }
}
```

### Rewarded Video

Similar to the Interstitial Ad, each instance of `StartAppRewardedVideoAd` can be displayed only once.
You have to load new instance in order to shown a rewarded video another time.
You must assign `null` to the corresponding field after the ad was shown.

```dart
class _MyAppState extends State<MyApp> {
  var startAppSdk = StartAppSdk();

  StartAppRewardedVideoAd? rewardedVideoAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(true);

    loadRewardedVideoAd();
  }

  void loadRewardedVideoAd() {
    startAppSdk.loadRewardedVideoAd(
      onAdNotDisplayed: () {
        debugPrint('onAdNotDisplayed: rewarded video');

        setState(() {
          // NOTE rewarded video ad can be shown only once
          this.rewardedVideoAd?.dispose();
          this.rewardedVideoAd = null;
        });
      },
      onAdHidden: () {
        debugPrint('onAdHidden: rewarded video');

        setState(() {
          // NOTE rewarded video ad can be shown only once
          this.rewardedVideoAd?.dispose();
          this.rewardedVideoAd = null;
        });
      },
      onVideoCompleted: () {
        debugPrint('onVideoCompleted: rewarded video completed, user gain a reward');

        setState(() {
          // TODO give reward to user
        });
      },
    ).then((rewardedVideoAd) {
      setState(() {
        this.rewardedVideoAd = rewardedVideoAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Rewarded Video ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Rewarded Video ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (rewardedVideoAd != null) {
            rewardedVideoAd!.show().onError((error, stackTrace) {
              debugPrint("Error showing Rewarded Video ad: $error");
              return false;
            });
          }
        },
        child: Text('Show Rewarded Video'),
      ),
    );
  }
}
```

### Native

In opposite to banners, native ad can't be refreshed automatically. You must take care about
interval of reloading native ads. Default interval for reloading banners is 45 seconds, which
can be good for native ads as well. Make sure you don't load native ad too frequently, cause this
may negatively impact your revenue.

IMPORTANT: You must not handle touch/click events from widgets of your native ad. Clicks are handled
by underlying view, so make sure your buttons or other widgets doesn't intercept touch/click events.

```dart
class _MyAppState extends State<MyApp> {
  var startAppSdk = StartAppSdk();

  StartAppNativeAd? nativeAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(true);

    startAppSdk.loadNativeAd().then((nativeAd) {
      setState(() {
        this.nativeAd = nativeAd;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Native ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Native ad: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: nativeAd != null
          ? // TODO build your own custom layout
          : Container(),
    );
  }
}
```

### Additional parameters

If you want to customize the ad request being sent to the server, you should pass an instance of
`StartAppAdPreferences` as named parameter `prefs` to any of loading method of class `StartAppSdk`.

You can find all available parameters in the constructor of `StartAppAdPreferences`.

**Examples**:

```dart
startAppSdk.loadBannerAd(type, prefs: const StartAppAdPreferences(
  adTag: 'home_screen',
));
```

```dart
startAppSdk.loadInterstitialAd(prefs: const StartAppAdPreferences(
  adTag: 'game_over',
));
```

```dart
startAppSdk.loadNativeAd(prefs: const StartAppAdPreferences(
  adTag: 'scoreboard',
));
```

### Listen ad events

If you want to do something when an ad event happens, you should pass a corresponding callback
while loading an ad.

**Note**: You have to call `interstitialAd.dispose()` after it has been used to prevent memory leak.
For banner it will be called automatically.

**Examples**:

```dart
startAppSdk.loadBannerAd(type,
  onAdImpression: () {
    // do something
  },
  onAdClicked: () {
    // do something
  },
);
```

```dart
startAppSdk.loadInterstitialAd(
  onAdDisplayed: () {
    // do something
  },
  onAdNotDisplayed: () {
    // do something

    interstitialAd.dispose();
    interstitialAd = null;
  },
  onAdClicked: () {
    // do something
  },
  onAdHidden: () {
    // do something

    interstitialAd.dispose();
    interstitialAd = null;
  },
);
```
