/**
 * Copyright 2022 Start.io Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "SdkPlugin.h"
#import <StartApp/StartApp.h>
#import "STAFPAdCallbackWrapper.h"
#import "STAFPBannerCallbackWrapper.h"
#import "STAFPItemsContainer.h"
#import "STAFPFlutterBannerViewFactory.h"
#import "STAFPFlutterNativeAdViewFactory.h"

static NSString *const kReturnAdsKey = @"com.startapp.sdk.RETURN_ADS_ENABLED";
static NSString *const kSplashAdsKey = @"com.startapp.sdk.SPLASH_ADS_ENABLED";
static NSString *const kApplicationIDKey = @"com.startapp.sdk.APPLICATION_ID";

static NSString *const kFlutterPluginVersion = @STA_PLUGIN_VERSION;

typedef NS_ENUM(NSUInteger, STAFlutterInterstitialAdMode) {
    STAFlutterInterstitialAdModeAutomatic = 0,
    STAFlutterInterstitialAdModeVideo = 1
};

@interface SdkPlugin ()

@property (nonatomic) id<STAFPItemsContainer> fullscreenAds;
@property (nonatomic) id<STAFPItemsContainer> banners;
@property (nonatomic) id<STAFPItemsContainer> nativeAds;

@property (nonatomic) FlutterMethodChannel *channel;

@end
@implementation SdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.startapp.flutter" binaryMessenger:[registrar messenger]];
    SdkPlugin *instance = [SdkPlugin new];
    instance.channel = channel;
    STAFPFlutterBannerViewFactory *bannersFactory = [[STAFPFlutterBannerViewFactory alloc] initWithItemsProvider:instance.banners];
    [registrar registerViewFactory:bannersFactory withId:@"com.startapp.flutter.Banner"];
    STAFPFlutterNativeAdViewFactory *nativeAdViewFactory = [[STAFPFlutterNativeAdViewFactory alloc] initWithItemsProvider:instance.nativeAds];
    [registrar registerViewFactory:nativeAdViewFactory withId:@"com.startapp.flutter.Native"];
    
    NSDictionary *infoDictionary = NSBundle.mainBundle.infoDictionary;
    
    STAStartAppSDK.sharedInstance.appID = infoDictionary[kApplicationIDKey];
    [STAStartAppSDK.sharedInstance addWrapperWithName:@"Flutter" version:kFlutterPluginVersion];
    
    NSNumber *returnAdEnabledValue =  infoDictionary[kReturnAdsKey];
    if ([returnAdEnabledValue isKindOfClass:[NSNumber class]]) {
        STAStartAppSDK.sharedInstance.returnAdEnabled = returnAdEnabledValue.boolValue;
    }
    NSNumber *splashAdEnabledValue =  infoDictionary[kSplashAdsKey];
    if ([splashAdEnabledValue isKindOfClass:[NSNumber class]] && splashAdEnabledValue.boolValue == YES) {
        [STAStartAppSDK.sharedInstance showSplashAd];
    }

    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getSdkVersion" isEqualToString:call.method]) {
        NSString *version = [STAStartAppSDK sharedInstance].version;
        result(version);
    } else if ([@"setTestAdsEnabled" isEqualToString:call.method]) {
        STAStartAppSDK.sharedInstance.testAdsEnabled = [@(YES) isEqual:call.arguments];
    } else if ([@"loadInterstitialAd" isEqualToString:call.method]) {
        [self loadInterstitialAdWithArguments:call.arguments flutterResult:result];
    } else if ([@"showInterstitialAd" isEqualToString:call.method]) {
        [self showInterstitialAdWithArguments:call.arguments flutterResult:result];
    } else if ([@"loadRewardedVideoAd" isEqualToString:call.method]) {
        [self loadRewardedVideoAdWithArguments:call.arguments flutterResult:result];
    } else if ([@"showRewardedVideoAd" isEqualToString:call.method]) {
        [self showInterstitialAdWithArguments:call.arguments flutterResult:result];
    } else if ([@"loadBannerAd" isEqualToString:call.method]) {
        [self loadBannerAdWithArguments:call.arguments flutterResult:result];
    } else if ([@"loadNativeAd" isEqualToString:call.method]) {
        [self loadNativeAdWithArguments:call.arguments flutterResult:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)loadInterstitialAdWithArguments:(NSDictionary *)arguments flutterResult:(FlutterResult)flutterResult {

    STAAdPreferences *adPreferences = [STAAdPreferences new];
    STASDKPreferences *sdkPreferences = STAStartAppSDK.sharedInstance.preferences;
    [self applyArguments:arguments toAdPreferences:&adPreferences sdkPreferences:&sdkPreferences];
    STAStartAppSDK.sharedInstance.preferences = sdkPreferences;
    
    STAStartAppAd *interstitalAd = [STAStartAppAd new];
    STASDKPluginItemIdentifier interstitialAdIdentifier = [self.fullscreenAds addItem:interstitalAd];
    
    STAFPAdCallbackWrapper *callbackWrapper = [self callbackWrapperForAdWithIdentifier:interstitialAdIdentifier flutterResult:flutterResult];
    
    NSNumber *mode = arguments[@"mode"];
    if ([mode isEqual:@(STAFlutterInterstitialAdModeVideo)]) {
        [interstitalAd loadVideoAdWithDelegate:callbackWrapper withAdPreferences:adPreferences];
    } else {
        [interstitalAd loadAdWithDelegate:callbackWrapper withAdPreferences:adPreferences];
    }
}

- (void)loadRewardedVideoAdWithArguments:(NSDictionary *)arguments flutterResult:(FlutterResult)flutterResult {
    
    STAAdPreferences *adPreferences = [STAAdPreferences new];
    STASDKPreferences *sdkPreferences = STAStartAppSDK.sharedInstance.preferences;
    [self applyArguments:arguments toAdPreferences:&adPreferences sdkPreferences:&sdkPreferences];
    STAStartAppSDK.sharedInstance.preferences = sdkPreferences;
    
    STAStartAppAd *interstitalAd = [STAStartAppAd new];
    STASDKPluginItemIdentifier interstitialAdIdentifier = [self.fullscreenAds addItem:interstitalAd];
    
    STAFPAdCallbackWrapper *callbackWrapper = [self callbackWrapperForAdWithIdentifier:interstitialAdIdentifier flutterResult:flutterResult];
    
    dispatch_block_t keepObjectsAliveTillFinishedBlock = ^{
        (void)callbackWrapper;
    };
    __weak typeof(self) weakSelf = self;
    
    callbackWrapper.didCompleteVideo = ^(STAAbstractAd * _Nonnull ad) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"videoCompleted" identifier:interstitialAdIdentifier];
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    [interstitalAd loadRewardedVideoAdWithDelegate:callbackWrapper withAdPreferences:adPreferences];
}

- (STAFPAdCallbackWrapper *)callbackWrapperForAdWithIdentifier:(STASDKPluginItemIdentifier)adIdentifier flutterResult:(FlutterResult)flutterResult {
    
    __block STAFPAdCallbackWrapper *callbackWrapper = [[STAFPAdCallbackWrapper alloc] initWithCallBacksQueue:dispatch_get_main_queue()];
    
    dispatch_block_t keepObjectsAliveTillFinishedBlock = ^{
        (void)callbackWrapper;
    };
    __weak typeof(self) weakSelf = self;
    callbackWrapper.didLoadAd = ^(STAAbstractAd * _Nonnull ad) {

        flutterResult( @{ @"id" : adIdentifier});
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.failedLoadAd = ^(STAAbstractAd * _Nonnull ad, NSError * _Nonnull error) {
        flutterResult([FlutterError errorWithCode:@"failed_to_receive_ad" message:error.localizedDescription details:nil]);
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.didShowAd = ^(STAAbstractAd * _Nonnull ad) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"adDisplayed" identifier:adIdentifier];
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.failedShowAd = ^(STAAbstractAd * _Nonnull ad, NSError * _Nonnull error) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"adNotDisplayed" identifier:adIdentifier];
        [theSelf.fullscreenAds removeItemWithIdentifier:adIdentifier];
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.didClickAd = ^(STAAbstractAd * _Nonnull ad) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"adClicked" identifier:adIdentifier];
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.didCloseAd = ^(STAAbstractAd * _Nonnull ad) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"adHidden" identifier:adIdentifier];
        [theSelf.fullscreenAds removeItemWithIdentifier:adIdentifier];
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.didSendImpression = ^(STAAbstractAd * _Nonnull ad) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"adImpression" identifier:adIdentifier];
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    return callbackWrapper;
}

- (void)loadBannerAdWithArguments:(NSDictionary *)arguments flutterResult:(FlutterResult)flutterResult {
    
    STAAdPreferences *adPreferences = [STAAdPreferences new];
    STASDKPreferences *sdkPreferences = STAStartAppSDK.sharedInstance.preferences;
    [self applyArguments:arguments toAdPreferences:&adPreferences sdkPreferences:&sdkPreferences];
    STAStartAppSDK.sharedInstance.preferences = sdkPreferences;
    
    STABannerSize bannerSize = STA_PortraitAdSize_320x50;
    NSNumber *type = arguments[@"type"];
    if ([type isEqual:@(STAFlutterBannerViewTypeMRec)]) {
        bannerSize = STA_MRecAdSize_300x250;
    } else if ([type isEqual:@(STAFlutterBannerViewTypeCover)]) {
        bannerSize = STA_CoverAdSize;
    }
    
    __block STAFPBannerCallbackWrapper *callbackWrapper = [[STAFPBannerCallbackWrapper alloc] initWithCallBacksQueue:dispatch_get_main_queue()];
    STABannerView *bannerView = [[STABannerView alloc] initWithSize:bannerSize autoOrigin:STAAdOrigin_Top withDelegate:callbackWrapper];
        STASDKPluginItemIdentifier bannerIdentifier = [self.banners addItem:bannerView];
    
    
    dispatch_block_t keepObjectsAliveTillFinishedBlock = ^{
        (void)callbackWrapper;
    };
    __weak typeof(self) weakSelf = self;
    callbackWrapper.didLoad = ^(STABannerView * _Nonnull banner) {

        flutterResult(
        @{
            @"id" : bannerIdentifier,
            @"width": @(bannerSize.size.width),
            @"height": @(bannerSize.size.height)
        });

        keepObjectsAliveTillFinishedBlock();
    };

    callbackWrapper.failedLoad = ^(STABannerView * _Nonnull banner, NSError * _Nonnull error) {
        flutterResult([FlutterError errorWithCode:@"failed_to_receive_ad" message:error.localizedDescription details:nil]);

        keepObjectsAliveTillFinishedBlock();
    };
    
    
    callbackWrapper.didClick = ^(STABannerView * _Nonnull banner) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"adClicked" identifier:bannerIdentifier];

        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.didSendImpression = ^(STABannerView * _Nonnull banner) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"adImpression" identifier:bannerIdentifier];

        keepObjectsAliveTillFinishedBlock();
    };
    
    [bannerView loadAd];
}

- (void) showInterstitialAdWithArguments:(NSDictionary *)arguments flutterResult:(FlutterResult)flutterResult {
    
    STASDKPluginItemIdentifier identifier = arguments[@"id"];
        if (identifier == nil) {
            flutterResult([FlutterError errorWithCode:@"no_id" message:nil details:nil]);
            return;
        }
        
    STAStartAppAd  *interstitialAd =  [self.fullscreenAds itemWithIdentifier:identifier];

        if (interstitialAd == nil) {
            flutterResult([FlutterError errorWithCode:@"ad_not_found" message:nil details:nil]);
            return;
        }
    [interstitialAd showAd];
    flutterResult(@(YES));
}

- (void)loadNativeAdWithArguments:(NSDictionary *)arguments flutterResult:(FlutterResult)flutterResult {

    STANativeAdPreferences *adPreferences = [STANativeAdPreferences new];
    adPreferences.adsNumber = 1;
    adPreferences.autoBitmapDownload = false;
    
    STASDKPreferences *sdkPreferences = STAStartAppSDK.sharedInstance.preferences;
    [self applyArguments:arguments toAdPreferences:&adPreferences sdkPreferences:&sdkPreferences];
    STAStartAppSDK.sharedInstance.preferences = sdkPreferences;
    
    STAStartAppNativeAd *nativeAd = [STAStartAppNativeAd new];
    __block STASDKPluginItemIdentifier nativeAdIdentifier = nil;
    
    __block STAFPAdCallbackWrapper *callbackWrapper = [[STAFPAdCallbackWrapper alloc] initWithCallBacksQueue:dispatch_get_main_queue()];
    
    dispatch_block_t keepObjectsAliveTillFinishedBlock = ^{
        (void)callbackWrapper;
        (void)nativeAd;
    };
    __weak typeof(self) weakSelf = self;
    callbackWrapper.didLoadAd = ^(STAAbstractAd * _Nonnull ad) {
        
        NSArray *adsDetatils = nativeAd.adsDetails;
        if (adsDetatils.count < 1) {
            flutterResult([FlutterError errorWithCode:@"no_fill" message:nil details:nil]);
        } else {
            
            STANativeAdDetails *adDetails = adsDetatils[0];
            nativeAdIdentifier = [weakSelf.nativeAds addItem:adDetails];

            NSMutableDictionary *flutterResultData = [NSMutableDictionary new];
            flutterResultData[@"id"] = nativeAdIdentifier;
            flutterResultData[@"title"] = adDetails.title;
            flutterResultData[@"description"] = adDetails.description;
            flutterResultData[@"rating"] = adDetails.rating;
            flutterResultData[@"category"] = adDetails.category;
            flutterResultData[@"callToAction"] = adDetails.callToAction;
            flutterResultData[@"imageUrl"] = adDetails.imageUrl;
            flutterResultData[@"secondaryImageUrl"] = adDetails.secondaryImageUrl;

            flutterResult(flutterResultData);

        }
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.failedLoadAd = ^(STAAbstractAd * _Nonnull ad, NSError * _Nonnull error) {
        flutterResult([FlutterError errorWithCode:@"failed_to_receive_ad" message:error.localizedDescription details:nil]);
        
        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.didClickNativeAd = ^(STANativeAdDetails * _Nonnull nativeAdDetails) {
        typeof(self) theSelf = weakSelf;

        [theSelf notifyAdEventWithType:@"adClicked" identifier:nativeAdIdentifier];

        keepObjectsAliveTillFinishedBlock();
    };
    
    callbackWrapper.didSendImpressionForNativeAd = ^(STANativeAdDetails * _Nonnull nativeAdDetails) {
        typeof(self) theSelf = weakSelf;
        
        [theSelf notifyAdEventWithType:@"adImpression" identifier:nativeAdIdentifier];
        keepObjectsAliveTillFinishedBlock();
        ;
    };
    
    [nativeAd loadAdWithDelegate:callbackWrapper withNativeAdPreferences:adPreferences];
}

- (void)notifyAdEventWithType:(NSString *)eventType identifier:(STASDKPluginItemIdentifier)identifier {
    NSDictionary *arguments = @{
        @"id": identifier,
        @"event": eventType
    };
    [self.channel invokeMethod:@"onAdEvent" arguments:arguments];
}

- (void)applyArguments:(NSDictionary *)arguments toAdPreferences:(STAAdPreferences **)ioPreferences sdkPreferences:(STASDKPreferences **)ioSDKPreferences {
    if (arguments == nil) {
        return;
    }
    
    STAAdPreferences *preferences = *ioPreferences;
    NSObject *adTag = arguments[@"adTag"];
    if ([adTag isKindOfClass:[NSString class]]) {
        preferences.adTag = (NSString *)adTag;
    }
    NSObject *minCPM = arguments[@"minCPM"];
    if ([minCPM isKindOfClass:[NSNumber class]]) {
        preferences.minCPM = ((NSNumber *)minCPM).doubleValue;
    }
        
    NSObject *genderValue = arguments[@"gender"];
    if ([@"m" isEqual:genderValue]) {
        STASDKPreferences *sdkPreferences = *ioSDKPreferences ?: [STASDKPreferences new];
        sdkPreferences.gender = STAGender_Male;
        *ioSDKPreferences = sdkPreferences;
        
    } else if ([@"f" isEqual:genderValue]) {
        STASDKPreferences *sdkPreferences = *ioSDKPreferences ?: [STASDKPreferences new];
        sdkPreferences.gender = STAGender_Female;
        *ioSDKPreferences = sdkPreferences;
    }
    
    NSObject *ageValue = arguments[@"age"];
    if ([ageValue isKindOfClass:[NSNumber class]]) {
        NSUInteger age = ((NSNumber *)ageValue).unsignedIntegerValue;
        STASDKPreferences *sdkPreferences = *ioSDKPreferences ?: [STASDKPreferences new];
        sdkPreferences.age = age;
        *ioSDKPreferences = sdkPreferences;
    }
}

#pragma mark -
- (id<STAFPItemsContainer>)fullscreenAds {
    if (nil == _fullscreenAds) {
        _fullscreenAds = [STAFPItemsContainer new];
    }
    return _fullscreenAds;
}

- (id<STAFPItemsContainer>)banners {
    if (nil == _banners) {
        _banners = [STAFPItemsContainer new];
    }
    return _banners;
}

- (id<STAFPItemsContainer>)nativeAds {
    if (nil == _nativeAds) {
        _nativeAds = [STAFPItemsContainer new];
    }
    return _nativeAds;
}

@end
