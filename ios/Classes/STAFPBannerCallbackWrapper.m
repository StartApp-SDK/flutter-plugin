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

#import "STAFPBannerCallbackWrapper.h"

@implementation STAFPBannerCallbackWrapper


- (void) bannerAdIsReadyToDisplay:(STABannerView *)banner {
    STAFPCallback callback = self.didLoad;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(banner);
        }];
    }
}

- (void) didDisplayBannerAd:(STABannerView *)banner {
    STAFPCallback callback = self.didShow;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(banner);
        }];
    }
}

- (void)didSendImpressionForBannerAd:(STABannerView *)banner {
    STAFPCallback callback = self.didSendImpression;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(banner);
        }];
    }
}
 
- (void) failedLoadBannerAd:(STABannerView *)banner withError:(NSError *)error {
    STAFPErrorCallback callback = self.failedLoad;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(banner, error);
        }];
    }
}

- (void) didClickBannerAd:(STABannerView *)banner {
    STAFPCallback callback = self.didClick;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(banner);
        }];
    }
}


@end


