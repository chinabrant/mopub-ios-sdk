//
//  MPAdViewOverlayDelegateMock.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdViewOverlayDelegateMock.h"

@implementation MPAdViewOverlayDelegateMock

- (void)adViewOverlay:(MPAdViewOverlay *)overlay didTriggerEvent:(MPVideoEvent)event {
    if (self.overlayDidTriggerEventBlock) {
        self.overlayDidTriggerEventBlock(overlay, event);
    }
}

- (void)adViewOverlayDidFinishCountdown:(MPAdViewOverlay *)overlay {
    if (self.overlayDidFinishCountdownBlock) {
        self.overlayDidFinishCountdownBlock(overlay);
    }
}

- (void)industryIconView:(nonnull MPVASTIndustryIconView *)iconView didTriggerEvent:(MPVASTResourceViewEvent)event {

}

- (void)industryIconView:(nonnull MPVASTIndustryIconView *)iconView didTriggerOverridingClickThrough:(nonnull NSURL *)url {

}

@end
