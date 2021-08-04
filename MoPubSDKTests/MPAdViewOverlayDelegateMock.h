//
//  MPAdViewOverlayDelegateMock.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdViewOverlay.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPAdViewOverlayDelegateMock : NSObject <MPAdViewOverlayDelegate>

@property (nonatomic, copy, nullable) void (^overlayDidTriggerEventBlock)(MPAdViewOverlay * _Nullable overlay, MPVideoEvent event);
@property (nonatomic, copy, nullable) void (^overlayDidFinishCountdownBlock)(MPAdViewOverlay * _Nullable overlay);

@end

NS_ASSUME_NONNULL_END
