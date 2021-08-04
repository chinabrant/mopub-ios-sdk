//
//  MPAdContainerViewMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdContainerViewMock.h"
#import "MPAdContainerView+Private.h"


@interface MPAdContainerViewMock ()
@property (nonatomic, assign, readwrite) BOOL isPaused;
@end

@implementation MPAdContainerViewMock

- (void)pauseVideo {
    self.isPaused = YES;
}

- (void)resume {
    self.isPaused = NO;
}

- (NSTimeInterval)countdownTimeForCurrentAdIndex {
    return self.mockCountdownTime;
}

@end
