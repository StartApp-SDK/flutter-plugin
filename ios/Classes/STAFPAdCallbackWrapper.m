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

#import "STAFPAdCallbackWrapper.h"


@implementation STAFPAdCallbackWrapper

- (void)didLoadAd:(STAAbstractAd *)ad {
    STAFPCallback callback = self.didLoadAd;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(ad);
        }];
    }
}

- (void)failedLoadAd:(STAAbstractAd *)ad withError:(NSError *)error {
    STAFPErrorCallback callback = self.failedLoadAd;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(ad, error);
        }];
    }
}

- (void)didShowAd:(STAAbstractAd *)ad {
    STAFPCallback callback = self.didShowAd;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(ad);
        }];
    }
}

- (void)didSendImpression:(STAAbstractAd *)ad {
    
}

- (void)failedShowAd:(STAAbstractAd *)ad withError:(NSError *)error {
    STAFPErrorCallback callback = self.failedShowAd;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(ad, error);
        }];
    }
}

- (void)didCloseAd:(STAAbstractAd *)ad {
    STAFPCallback callback = self.didCloseAd;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(ad);
        }];
    }
}

- (void)didClickAd:(STAAbstractAd *)ad {
    STAFPCallback callback = self.didClickAd;
    if (nil != callback) {
        [self performCallBackOnCorrectQueue:^{
            callback(ad);
        }];
    }
}

- (void)didCloseInAppStore:(STAAbstractAd *)ad {
    
}

- (void)didCompleteVideo:(STAAbstractAd *)ad {
    
}

- (void)didSendImpressionForNativeAdDetails:(STANativeAdDetails *)nativeAdDetails {
    
}

- (void)didClickNativeAdDetails:(STANativeAdDetails *)nativeAdDetails {
    
}

@end


