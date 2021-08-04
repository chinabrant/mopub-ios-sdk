//
//  MPVideoPlayerViewMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPVideoPlayerViewMock.h"

@interface MPVideoPlayerViewMock ()
@property (nonatomic, assign, readwrite) BOOL videoDidBeginPlayback;
@property (nonatomic, assign, readwrite) BOOL isPaused;
@property (nonatomic, assign, readwrite) BOOL didCallStop;
@end

@implementation MPVideoPlayerViewMock

- (BOOL)isVideoPlaying {
    return self.videoDidBeginPlayback;
}

- (void)playVideo {
    self.videoDidBeginPlayback = YES;
    self.isPaused = NO;
}

- (void)pauseVideo {
    self.isPaused = YES;
}

- (void)stopVideo {
    self.didCallStop = YES;
}

@end
