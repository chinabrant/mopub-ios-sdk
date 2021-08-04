//
//  MPAdContainerViewMock.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPAdContainerViewMock : MPAdContainerView
@property (nonatomic, assign, readonly) BOOL isPaused;
@property (nonatomic, assign) NSTimeInterval mockCountdownTime;
@end

NS_ASSUME_NONNULL_END
