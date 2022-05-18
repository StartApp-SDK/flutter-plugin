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

#import "STAFPItemsContainer.h"

@interface STAFPItemsContainer()
@property (nonatomic) NSMutableDictionary *items;
@end

@implementation STAFPItemsContainer

static NSInteger sCounter = 0;
- (STASDKPluginItemIdentifier)addItem:(id)item {
    NSAssert(NSThread.isMainThread, @"main thread only");
    sCounter ++;

    STASDKPluginItemIdentifier identifier = @(sCounter);
    self.items[identifier] = item;
    return  identifier;
}

- (void)removeItemWithIdentifier:(STASDKPluginItemIdentifier)identifier {
    NSAssert(NSThread.isMainThread, @"main thread only");
    
    [self.items removeObjectForKey:identifier];
}
- (id)itemWithIdentifier:(STASDKPluginItemIdentifier)identifier {
    NSAssert(NSThread.isMainThread, @"main thread only");

    return  self.items[identifier];
}

#pragma mark -
- (NSMutableDictionary *)items {
    if (nil == _items) {
        _items =  [NSMutableDictionary new];
    }
    return _items;
}


@end
