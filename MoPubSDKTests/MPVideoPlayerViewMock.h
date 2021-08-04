//
//  MPVideoPlayerViewMock.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVideoPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVideoPlayerViewMock : MPVideoPlayerView
@property (nonatomic, assign, readonly) BOOL isPaused;
@property (nonatomic, assign, readonly) BOOL didCallStop;
@end

NS_ASSUME_NONNULL_END
