//
//  HooPhotoLoadingView.h
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat kMinProgress = 0.0001f;

@interface HooPhotoLoadingView : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, copy) NSString *failureTip;

- (void)showLoading;

- (void)showFailure;
@end
