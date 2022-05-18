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

#import "STAFPCallbackWrapper.h"

@implementation STAFPCallbackWrapper

- (instancetype)initWithCallBacksQueue:(nullable dispatch_queue_t)callBacksQueue {
    self = [super init];
    _callBacksQueue = callBacksQueue;
    return  self;
}

- (instancetype)init {
    return [self initWithCallBacksQueue:nil];
}

- (void)performCallBackOnCorrectQueue:(dispatch_block_t)callback {
    if (nil == self.callBacksQueue) {
        callback();
    } else {
        dispatch_async(self.callBacksQueue, callback);
    }
}

@end
