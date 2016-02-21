//
//  HooPhoto.m
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import "HooPhoto.h"

@implementation HooPhoto

- (void)setSourceImageView:(UIImageView *)sourceImageView {
    _sourceImageView = sourceImageView;
    _placeholderImage = sourceImageView.image;
    if (sourceImageView.clipsToBounds) {
        _capturedImage = [self capture:sourceImageView];
    }
}

- (UIImage *)capture:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
