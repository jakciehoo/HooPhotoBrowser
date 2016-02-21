//
//  HooPhotoLoadingView.m
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import "HooPhotoLoadingView.h"
#import "HooPhotoProgressView.h"

@interface HooPhotoLoadingView (){
    UILabel *_failureLabel;
    HooPhotoProgressView *_progressView;
}
@end

@implementation HooPhotoLoadingView

#pragma mark - Getter and Setter

- (void)setFrame:(CGRect)frame
{
    [super setFrame:[UIScreen mainScreen].bounds];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _progressView.progress = progress;
    if (progress >= 1.0) {
        [_progressView removeFromSuperview];
    }
}

- (void)showLoading {
    [_failureLabel removeFromSuperview];
    
    if (_progressView == nil) {
        _progressView = [[HooPhotoProgressView alloc] init];
        _progressView.bounds = CGRectMake( 0, 0, 60, 60);
        _progressView.center = self.center;
    }
    _progressView.progress = kMinProgress;
    [self addSubview:_progressView];
}

- (void)showFailure {
    [_progressView removeFromSuperview];
    
    if (_failureLabel == nil) {
        _failureLabel = [[UILabel alloc] init];
        _failureLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, 44);
        _failureLabel.textAlignment = NSTextAlignmentCenter;
        _failureLabel.center = self.center;
        _failureLabel.text = self.failureTip.length ? self.failureTip : @"网络不给力，图片下载失败";
        _failureLabel.font = [UIFont boldSystemFontOfSize:20];
        _failureLabel.textColor = [UIColor whiteColor];
        _failureLabel.backgroundColor = [UIColor clearColor];
        _failureLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    [self addSubview:_failureLabel];
}

@end
