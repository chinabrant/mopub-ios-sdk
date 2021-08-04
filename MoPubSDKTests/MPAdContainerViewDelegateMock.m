//
//  MPAdContainerViewDelegateMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdContainerViewDelegateMock.h"

@implementation MPAdContainerViewDelegateMock

- (void)containerViewAdExperienceDidFinish:(MPAdContainerView *)containerView {
    if (self.containerDidFinishAdExperience) {
        self.containerDidFinishAdExperience(containerView);
    }
}

@end
