//
//  MPAdContainerViewDelegateMock.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPAdContainerViewDelegateMock : NSObject <MPAdContainerViewDelegate>
@property (nonatomic, copy, nullable) void (^containerDidFinishAdExperience)(MPAdContainerView * _Nullable container);
@end

NS_ASSUME_NONNULL_END
