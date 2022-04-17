import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var startAppSdk = StartAppSdk();
  var _sdkVersion = "";

  StartAppBannerAd? bannerAd;
  StartAppBannerAd? mrecAd;
  StartAppInterstitialAd? interstitialAd;
  StartAppNativeAd? nativeAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(true);

    // TODO your app doesn't need to call this method unless for debug purposes
    startAppSdk.getSdkVersion().then((value) {
      setState(() => _sdkVersion = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("StartApp SDK $_sdkVersion"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => startAppSdk
                      .loadInterstitialAd(
                          prefs: const StartAppAdPreferences(adTag: 'home_screen'),
                          onAdDisplayed: () {
                            debugPrint('onAdDisplayed: interstitial');
                          },
                          onAdNotDisplayed: () {
                            debugPrint('onAdNotDisplayed: interstitial');

                            setState(() {
                              // NOTE interstitial ad can be shown only once
                              this.interstitialAd?.dispose();
                              this.interstitialAd = null;
                            });
                          },
                          onAdClicked: () {
                            debugPrint('onAdClicked: interstitial');
                          },
                          onAdHidden: () {
                            debugPrint('onAdHidden: interstitial');

                            setState(() {
                              // NOTE interstitial ad can be shown only once
                              this.interstitialAd?.dispose();
                              this.interstitialAd = null;
                            });
                          })
                      .then((interstitialAd) {
                    setState(() {
                      this.interstitialAd = interstitialAd;
                    });
                  }).onError<StartAppException>((ex, stackTrace) {
                    debugPrint("Error loading Interstitial ad: ${ex.message}");
                  }).onError((error, stackTrace) {
                    debugPrint("Error loading Interstitial ad: $error");
                  }),
                  child: Text('Load Interstitial'),
                ),
                ElevatedButton(
                  onPressed: (StartAppInterstitialAd? interstitialAd) {
                    if (interstitialAd != null) {
                      return () => interstitialAd.show().onError((error, stackTrace) {
                            debugPrint("Error showing Interstitial ad: $error");
                            return false;
                          });
                    } else {
                      return null;
                    }
                  }(interstitialAd),
                  child: Text('Show Interstitial'),
                ),
                bannerAd != null
                    ? StartAppBanner(bannerAd!)
                    : ElevatedButton(
                        onPressed: () => startAppSdk.loadBannerAd(
                          StartAppBannerType.BANNER,
                          prefs: const StartAppAdPreferences(adTag: 'primary'),
                          onAdImpression: () {
                            debugPrint('onAdImpression: banner');
                          },
                          onAdClicked: () {
                            debugPrint('onAdClicked: banner');
                          },
                        ).then((bannerAd) {
                          setState(() {
                            this.bannerAd = bannerAd;
                          });
                        }).onError<StartAppException>((ex, stackTrace) {
                          debugPrint("Error loading Banner ad: ${ex.message}");
                        }).onError((error, stackTrace) {
                          debugPrint("Error loading Banner ad: $error");
                        }),
                        child: Text('Show Banner'),
                      ),
                mrecAd != null
                    ? StartAppBanner(mrecAd!)
                    : ElevatedButton(
                  onPressed: () => startAppSdk.loadBannerAd(StartAppBannerType.MREC, prefs: const StartAppAdPreferences(adTag: 'secondary')).then((mrecAd) {
                          setState(() {
                            this.mrecAd = mrecAd;
                          });
                        }).onError<StartAppException>((ex, stackTrace) {
                          debugPrint("Error loading Mrec ad: ${ex.message}");
                        }).onError((error, stackTrace) {
                          debugPrint("Error loading Mrec ad: $error");
                        }),
                        child: Text('Show Mrec'),
                      ),
                nativeAd != null
                    ? Container(
                        color: Colors.blueGrey.shade50,
                        child: StartAppNative(
                          nativeAd!,
                          (context, setState, nativeAd) {
                            return Row(
                              children: [
                                nativeAd.imageUrl != null
                                    ? SizedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Image.network(nativeAd.imageUrl!),
                                        ),
                                        width: 160,
                                        height: 160,
                                      )
                                    : Container(),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Title: ${nativeAd.title}', maxLines: 1),
                                      Text('Description: ${nativeAd.description}', maxLines: 1),
                                      Text('Rating: ${nativeAd.rating}', maxLines: 1),
                                      Text('Installs: ${nativeAd.installs}', maxLines: 1),
                                      Text('Category: ${nativeAd.category}', maxLines: 1),
                                      Text('Campaign: ${nativeAd.campaign}', maxLines: 1),
                                      Text('Call to action: ${nativeAd.callToAction}', maxLines: 1),
                                      Text('Image 1: ${cutString(nativeAd.imageUrl, 20)}', maxLines: 1),
                                      Text('Image 2: ${cutString(nativeAd.secondaryImageUrl, 20)}', maxLines: 1),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          height: 160,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => startAppSdk.loadNativeAd(const StartAppAdPreferences(adTag: 'game_over')).then((nativeAd) {
                          setState(() {
                            this.nativeAd = nativeAd;
                          });
                        }).onError<StartAppException>((ex, stackTrace) {
                          debugPrint("Error loading Native ad: ${ex.message}");
                        }).onError((error, stackTrace) {
                          debugPrint("Error loading Native ad: $error");
                        }),
                        child: Text('Show Native'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? cutString(String? input, int length) {
    if (input != null && input.length > length) {
      return input.substring(0, length) + '...';
    }

    return input;
  }
}
