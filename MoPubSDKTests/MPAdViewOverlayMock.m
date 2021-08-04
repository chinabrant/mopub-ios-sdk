//
//  MPAdViewOverlayMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdViewOverlayMock.h"

@interface MPAdViewOverlayMock ()
@property (nonatomic, assign, readwrite) BOOL isPaused;
@end

@implementation MPAdViewOverlayMock

- (void)pause {
    self.isPaused = YES;
}

- (void)resume {
    self.isPaused = NO;
}

@end
