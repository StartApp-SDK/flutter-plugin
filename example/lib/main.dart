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
  StartAppRewardedVideoAd? rewardedVideoAd;
  StartAppNativeAd? nativeAd;
  int? reward;

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
    var buttonStyle = ButtonStyle(minimumSize: WidgetStateProperty.all(Size(224, 36)));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Start.io SDK $_sdkVersion"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    startAppSdk.loadInterstitialAd(
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
                      },
                    ).then((interstitialAd) {
                      setState(() {
                        this.interstitialAd = interstitialAd;
                      });
                    }).onError<StartAppException>((ex, stackTrace) {
                      debugPrint("Error loading Interstitial ad: ${ex.message}");
                    }).onError((error, stackTrace) {
                      debugPrint("Error loading Interstitial ad: $error");
                    });
                  },
                  child: Text('Load Interstitial'),
                ),
                ElevatedButton(
                  style: buttonStyle,
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
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    startAppSdk.loadRewardedVideoAd(
                      prefs: const StartAppAdPreferences(adTag: 'home_screen_rewarded_video'),
                      onAdDisplayed: () {
                        debugPrint('onAdDisplayed: rewarded video');
                      },
                      onAdNotDisplayed: () {
                        debugPrint('onAdNotDisplayed: rewarded video');

                        setState(() {
                          // NOTE rewarded video ad can be shown only once
                          this.rewardedVideoAd?.dispose();
                          this.rewardedVideoAd = null;
                        });
                      },
                      onAdClicked: () {
                        debugPrint('onAdClicked: rewarded video');
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
                          reward = reward != null ? reward! + 1 : 1;
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
                  },
                  child: Text('Load Rewarded Video'),
                ),
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: (StartAppRewardedVideoAd? rewardedVideoAd) {
                    if (rewardedVideoAd != null) {
                      return () => rewardedVideoAd.show().onError((error, stackTrace) {
                            debugPrint("Error showing Rewarded Video ad: $error");
                            return false;
                          });
                    } else {
                      return null;
                    }
                  }(rewardedVideoAd),
                  child: Text(reward != null ? 'Show Rewarded Video ($reward)' : 'Show Rewarded Video'),
                ),
                bannerAd != null
                    ? StartAppBanner(bannerAd!)
                    : ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          startAppSdk.loadBannerAd(
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
                          });
                        },
                        child: Text('Show Banner'),
                      ),
                mrecAd != null
                    ? StartAppBanner(mrecAd!)
                    : ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          startAppSdk.loadBannerAd(
                            StartAppBannerType.MREC,
                            prefs: const StartAppAdPreferences(adTag: 'secondary'),
                          ).then((mrecAd) {
                            setState(() {
                              this.mrecAd = mrecAd;
                            });
                          }).onError<StartAppException>((ex, stackTrace) {
                            debugPrint("Error loading Mrec ad: ${ex.message}");
                          }).onError((error, stackTrace) {
                            debugPrint("Error loading Mrec ad: $error");
                          });
                        },
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
                          height: 180,
                        ),
                      )
                    : ElevatedButton(
                        style: buttonStyle,
                        onPressed: () {
                          startAppSdk.loadNativeAd(
                            prefs: const StartAppAdPreferences(adTag: 'game_over'),
                            onAdImpression: () {
                              debugPrint('onAdImpression: nativeAd');
                            },
                            onAdClicked: () {
                              debugPrint('onAdClicked: nativeAd');
                            },
                          ).then((nativeAd) {
                            setState(() {
                              this.nativeAd = nativeAd;
                            });
                          }).onError<StartAppException>((ex, stackTrace) {
                            debugPrint("Error loading Native ad: ${ex.message}");
                          }).onError((error, stackTrace) {
                            debugPrint("Error loading Native ad: $error");
                          });
                        },
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
