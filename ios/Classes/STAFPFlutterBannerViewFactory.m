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

#import "STAFPFlutterBannerViewFactory.h"
#import <StartApp/StartApp.h>
#import "STAFPItemsContainer.h"

@implementation STAFPFlutterBannerViewFactory

- (instancetype)initWithItemsProvider:(id<STAFPItemsContainer>)itemsProvider {
    self = [super init];
    _itemsProvider = itemsProvider;
    return  self;
}


- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(nullable NSDictionary *)args {

    NSString *error = nil;
    UIView *nativeView = nil;

    STASDKPluginItemIdentifier adIdentifier = args[@"adId"];
    if (nil == adIdentifier) {
        error = @"no_ad_id";
    } else {
        nativeView = [self.itemsProvider itemWithIdentifier:adIdentifier];
        if (nativeView == nil) {
            error = @"no_ad_instance";
        }
    }

    if (nativeView == nil) {
        nativeView = [[UIView alloc] initWithFrame:frame];
        NSLog(@"%@ createWithFrame:%@, viewIdentifier:%@, args:%@ failed with error:%@", self, NSStringFromCGRect(frame), @(viewId), args, error);
    }

    return [[STAFlutterPlatformView alloc] initWithNativeView:nativeView];
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
    return FlutterStandardMessageCodec.sharedInstance;
}

@end
