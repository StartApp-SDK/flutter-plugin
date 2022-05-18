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

#import "STAFPFlutterViewFactory.h"
#import "STAFPItemsContainer.h"

@interface STAFlutterPlatformView ()
@property (nonatomic, readonly) UIView *nativeView;
@end

@implementation STAFlutterPlatformView

- (instancetype)initWithNativeView:(UIView *)nativeView {
    self = [super init];
    _nativeView = nativeView;
    return  self;
}

- (nonnull UIView *)view {
    return self.nativeView;
}

@end

@implementation STAFPFlutterViewFactory

- (instancetype)initWithItemsProvider:(id<STAFPItemsContainer>)itemsProvider {
    self = [super init];
    _itemsProvider = itemsProvider;
    return  self;
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
    return FlutterStandardMessageCodec.sharedInstance;
}

@end
