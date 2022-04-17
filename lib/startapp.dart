import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Singleton class for accessing API of native platform Start.io (StartApp) SDK.
class StartAppSdk {
  static final StartAppSdk _instance = StartAppSdk._();

  final MethodChannel _channel = const MethodChannel('com.startapp.flutter');

  final Map<int, VoidCallback> onAdDisplayedCallbacks = Map();
  final Map<int, VoidCallback> onAdNotDisplayedCallbacks = Map();
  final Map<int, VoidCallback> onAdClickedCallbacks = Map();
  final Map<int, VoidCallback> onAdHiddenCallbacks = Map();
  final Map<int, VoidCallback> onAdImpressionCallbacks = Map();

  /// It's safe to call this constructor several time, it returns singleton instance.
  factory StartAppSdk() {
    return _instance;
  }

  StartAppSdk._() {
    Map<String, Map<int, VoidCallback>> adEventCallbacks = {
      'adDisplayed': onAdDisplayedCallbacks,
      'adNotDisplayed': onAdNotDisplayedCallbacks,
      'adClicked': onAdClickedCallbacks,
      'adHidden': onAdHiddenCallbacks,
      'adImpression': onAdImpressionCallbacks,
    };

    _channel.setMethodCallHandler((call) {
      if (call.method == 'onAdEvent') {
        dynamic args = call.arguments;
        if (args is Map) {
          dynamic id = args['id'];
          dynamic event = args['event'];

          if (id is int && event is String) {
            var map = adEventCallbacks[event];
            if (map != null) {
              var callback = map[id];
              if (callback != null) {
                callback();
              }
            }
          }
        }
      }

      return Future.value(null);
    });
  }

  void _removeCallbacks(int id) {
    onAdDisplayedCallbacks.remove(id);
    onAdNotDisplayedCallbacks.remove(id);
    onAdClickedCallbacks.remove(id);
    onAdHiddenCallbacks.remove(id);
    onAdImpressionCallbacks.remove(id);
  }

  /// Returns the version of underlying native platform SDK.
  Future getSdkVersion() {
    return _channel.invokeMethod('getSdkVersion');
  }

  /// Enables test ads.
  Future setTestAdsEnabled(bool value) {
    return _channel.invokeMethod('setTestAdsEnabled', value);
  }

  /// Loads banner ad, creates an underlying native platform view.
  ///
  /// Once loaded the banner must be shown immediately with [StartAppBanner].
  /// Banner will be refreshed automatically.
  Future<StartAppBannerAd> loadBannerAd(
    StartAppBannerType type, {
    StartAppAdPreferences prefs = const StartAppAdPreferences(),
    VoidCallback? onAdImpression,
    VoidCallback? onAdClicked,
  }) {
    return _channel.invokeMethod('loadBannerAd', prefs._toMap({'type': type.index})).then((value) {
      if (value is Map) {
        dynamic id = value['id'];

        if (id is int && id > 0) {
          if (onAdImpression != null) {
            onAdImpressionCallbacks[id] = onAdImpression;
          }

          if (onAdClicked != null) {
            onAdClickedCallbacks[id] = onAdClicked;
          }

          return StartAppBannerAd._(id, value.cast());
        }
      }

      throw StartAppException(message: value);
    });
  }

  /// Loads interstitial ad, does not create an underlying native platform view.
  ///
  /// This type of ad can be displayed later during natural UI transition in your app.
  /// Each instance of [StartAppInterstitialAd] can be displayed only once.
  /// You have to load new instance in order to shown an interstitial ad another time.
  /// You must assign [null] to the corresponding field after the ad was shown.
  Future<StartAppInterstitialAd> loadInterstitialAd({
    StartAppAdPreferences prefs = const StartAppAdPreferences(),
    VoidCallback? onAdDisplayed,
    VoidCallback? onAdNotDisplayed,
    VoidCallback? onAdClicked,
    VoidCallback? onAdHidden,
  }) {
    return _channel.invokeMethod('loadInterstitialAd', prefs._toMap()).then((value) {
      if (value is Map) {
        dynamic id = value['id'];

        if (id is int && id > 0) {
          if (onAdDisplayed != null) {
            onAdDisplayedCallbacks[id] = onAdDisplayed;
          }

          if (onAdNotDisplayed != null) {
            onAdNotDisplayedCallbacks[id] = onAdNotDisplayed;
          }

          if (onAdClicked != null) {
            onAdClickedCallbacks[id] = onAdClicked;
          }

          if (onAdHidden != null) {
            onAdHiddenCallbacks[id] = onAdHidden;
          }

          return StartAppInterstitialAd._(id, _channel);
        }
      }

      throw StartAppException(message: value);
    });
  }

  /// Loads native ad, does not create an underlying native platform view.
  ///
  /// Once loaded the native ad must be shown with [StartAppNative].
  /// In opposite to banners, native ad can't be refreshed automatically.
  /// You must take care about interval of reloading native ads.
  /// Default interval for reloading banners is 45 seconds, which can be good for native ads as well.
  /// Make sure you don't load native ad too frequently, cause this may negatively impact your revenue.
  ///
  /// IMPORTANT: You must not handle touch/click events from widgets of your native ad. Clicks are handled
  /// by underlying view, so make sure your buttons or other widgets doesn't intercept touch/click events.
  Future<StartAppNativeAd> loadNativeAd([
    StartAppAdPreferences prefs = const StartAppAdPreferences(),
  ]) {
    return _channel.invokeMethod('loadNativeAd', prefs._toMap()).then((value) {
      if (value is Map) {
        dynamic id = value['id'];

        if (id is int && id > 0) {
          return StartAppNativeAd._(id, value.cast());
        }
      }

      throw StartAppException(message: value);
    });
  }
}

/// Class with parameters to be passed into methods [StartAppSdk.loadBannerAd()],
/// [StartAppSdk.loadInterstitialAd()], [StartAppSdk.loadNativeAd()].
class StartAppAdPreferences {
  /// Ad tag is used to distinguish different placements within your app.
  /// Also know as 'ad unit', 'placement id', etc.
  final String? adTag;

  /// Specify keywords of the content within certain placement within your app.
  final String? keywords;

  /// Pass gender of your user if you know it.
  final String? gender;

  /// Pass age of your user if you know it.
  final int? age;

  /// Pass [true] if you prefer to mute video ad.
  final bool? videoMuted;

  /// Pass [true] if you prefer to use hardware acceleration.
  final bool? hardwareAccelerated;

  /// Pass categories of the ad you want to load.
  final List<String>? categories;

  /// Pass categories of the ad you do not want to load.
  final List<String>? categoriesExclude;

  /// Desired width of an ad. Only applicable for [StartAppBannerAd].
  final int? desiredWidth;

  /// Desired height of an ad. Only applicable for [StartAppBannerAd].
  final int? desiredHeight;

  const StartAppAdPreferences({
    this.adTag,
    this.keywords,
    this.gender,
    this.age,
    this.videoMuted,
    this.hardwareAccelerated,
    this.categories,
    this.categoriesExclude,
    this.desiredWidth,
    this.desiredHeight,
  });

  Map<String, dynamic> _toMap([Map<String, dynamic>? map]) {
    if (map == null) {
      map = {};
    }

    map.addAll({
      'adTag': adTag,
      'keywords': keywords,
      'gender': gender,
      'age': age,
      'videoMuted': videoMuted,
      'hardwareAccelerated': hardwareAccelerated,
      'categories': categories,
      'categoriesExclude': categoriesExclude,
      'desiredWidth': desiredWidth,
      'desiredHeight': desiredHeight,
    });

    return map;
  }
}

/// Type of the banner.
enum StartAppBannerType {
  /// 320x50
  BANNER,

  /// 300x250
  MREC,

  /// 1200x628
  COVER,
}

class _StartAppAd {
  final int _id;

  _StartAppAd(this._id);

  void dispose() {
    StartAppSdk._instance._removeCallbacks(_id);
  }
}

abstract class _StartAppStatefulWidget<Ad extends _StartAppAd> extends StatefulWidget {
  final Ad _ad;

  _StartAppStatefulWidget(this._ad);

  void dispose() {
    _ad.dispose();
  }
}

/// Proxy object which holds an underlying native platform view.
class StartAppBannerAd extends _StartAppAd {
  final Map<String, dynamic> _data;

  StartAppBannerAd._(id, this._data) : super(id);

  /// Returns a width of the widget.
  double? get width {
    dynamic value = _data['width'];
    return value is num ? value.toDouble() : null;
  }

  /// Returns a height of the widget.
  double? get height {
    dynamic value = _data['height'];
    return value is num ? value.toDouble() : null;
  }
}

/// Widget to display [StartAppBannerAd].
class StartAppBanner extends _StartAppStatefulWidget<StartAppBannerAd> {
  StartAppBanner(StartAppBannerAd ad) : super(ad);

  @override
  State createState() {
    return _StartAppAndroidViewState(
      'com.startapp.flutter.Banner',
      creationParams: {
        'adId': _ad._id,
      },
      width: _ad.width,
      height: _ad.height,
    );
  }
}

/// Proxy object which holds an interstitial ad ready to be shown.
class StartAppInterstitialAd extends _StartAppAd {
  final MethodChannel _channel;

  StartAppInterstitialAd._(id, this._channel) : super(id);

  /// Show an ad.
  Future<bool> show() {
    return _channel.invokeMethod('showInterstitialAd', {
      'id': _id,
    }).then((value) {
      return value is bool && value;
    });
  }
}

/// Proxy object which holds a native ad ready to be shown.
class StartAppNativeAd extends _StartAppAd {
  final Map<String, dynamic> _data;

  StartAppNativeAd._(id, this._data) : super(id);

  /// The main line of an ad, which must stands out well
  String? get title {
    return _data['title'];
  }

  /// The secondary text of an ad, which must have less visual accent comparing to the [title].
  String? get description {
    return _data['description'];
  }

  /// Rating of an app or website which is advertised.
  double? get rating {
    return _data['rating'];
  }

  /// Number of app installs.
  String? get installs {
    return _data['installs'];
  }

  /// Category of app or website.
  String? get category {
    return _data['category'];
  }

  /// Type of campaign.
  String? get campaign {
    return _data['campaign'];
  }

  /// Title which must be displayed within the main button of an ad.
  String? get callToAction {
    return _data['callToAction'];
  }

  /// URL of the main image of an ad.
  String? get imageUrl {
    return _data['imageUrl'];
  }

  /// URL of the secondary image of an ad.
  String? get secondaryImageUrl {
    return _data['secondaryImageUrl'];
  }
}

typedef StartAppNativeWidgetBuilder = Widget Function(BuildContext context, StateSetter setState, StartAppNativeAd nativeAd);

/// Parent widget to display [StartAppNativeAd], your main layout will be requested via [StartAppNativeWidgetBuilder].
class StartAppNative extends _StartAppStatefulWidget<StartAppNativeAd> {
  final StartAppNativeWidgetBuilder _builder;
  final double? width;
  final double? height;
  final bool ignorePointer;

  StartAppNative(
    StartAppNativeAd ad,
    this._builder, {
    this.width,
    this.height,
    this.ignorePointer = true,
  }) : super(ad);

  @override
  State<StatefulWidget> createState() {
    return _StartAppAndroidViewState(
      'com.startapp.flutter.Native',
      creationParams: {
        'adId': _ad._id,
        'width': width,
        'height': height,
      },
      width: width,
      height: height,
      overlayBuilder: (context, setState) {
        return IgnorePointer(
          ignoring: ignorePointer,
          child: _builder(context, setState, _ad),
        );
      },
    );
  }
}

class _StartAppAndroidViewState extends State<_StartAppStatefulWidget> {
  final String viewType;
  final Map<String, dynamic> creationParams;
  final double? width;
  final double? height;
  final StatefulWidgetBuilder? overlayBuilder;

  _StartAppAndroidViewState(
    this.viewType, {
    this.creationParams = const {},
    this.width,
    this.height,
    this.overlayBuilder,
  });

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          PlatformViewLink(
            viewType: viewType,
            surfaceFactory: (BuildContext context, PlatformViewController controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: StandardMessageCodec(),
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..create();
            },
          ),
          overlayBuilder != null ? StatefulBuilder(builder: overlayBuilder!) : Container(),
        ],
      ),
    );
  }
}

class StartAppException implements Exception {
  final dynamic message;

  StartAppException({this.message});
}
