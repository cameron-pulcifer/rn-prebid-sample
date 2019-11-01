//
//  CounterViewManager.m
//  SecondCocoa
//
//  Created by Cameron Pulcifer on 10/10/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(CounterViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(count, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(onUpdate, RCTDirectEventBlock)
RCT_EXTERN_METHOD(updateFromManager:(nonnull NSNumber *)node count:(nonnull NSNumber *)count)

@end
