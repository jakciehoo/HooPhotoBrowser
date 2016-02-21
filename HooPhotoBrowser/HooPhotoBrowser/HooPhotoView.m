//
//  HooPhotoView.m
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import "HooPhotoView.h"
#import "HooPhotoLoadingView.h"
#import "HooPhoto.h"
#import "UIImageView+WebCache.h"

@interface HooPhotoView ()<UIScrollViewDelegate> {
    BOOL _isDoubleTap;
    UIImageView *_imageView;
    HooPhotoLoadingView *_photoLoadingView;
}

@end

@implementation HooPhotoView

#pragma mark - Getter and Setter

- (void)setPhoto:(HooPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        _photoLoadingView = [[HooPhotoLoadingView alloc] init];
        
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)showImage {
    if (_photo.isFirstShow) {
        _imageView.image = _photo.placeholderImage;
        _photo.sourceImageView.image = nil;
        
        if (![_photo.url.absoluteString hasSuffix:@"gif"]) {
            __weak HooPhotoView *photoView = self;
            __weak HooPhoto *photo = _photo;
            
            [_imageView sd_setImageWithURL:_photo.url placeholderImage:_photo.placeholderImage options:SDWebImageRetryFailed|SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                photo.image = image;

                [photoView adjustFrame];
            }];
        }
    } else {
        [self photoStartLoad];
    }
    
    [self adjustFrame];
}

- (void)photoStartLoad {
    if (_photo.image) {
        self.scrollEnabled = YES;
        _imageView.image = _photo.image;
    } else {
        self.scrollEnabled = NO;

        [_photoLoadingView showLoading];
        [self addSubview:_photoLoadingView];
        
        __weak HooPhotoView *photoView = self;
        __weak HooPhotoLoadingView *loadingView = _photoLoadingView;
        
        [_imageView sd_setImageWithURL:_photo.url placeholderImage:_photo.sourceImageView.image options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (receivedSize > kMinProgress) {
                loadingView.progress = (float)receivedSize/expectedSize;
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [photoView photoDidFinishLoadWithImage:image];
        }];
        
    }
}

- (void)photoDidFinishLoadWithImage:(UIImage *)image {
    if (image) {
        self.scrollEnabled = YES;
        _photo.image = image;
        [_photoLoadingView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    } else {
        [self addSubview:_photoLoadingView];
        [_photoLoadingView showFailure];
    }
    
    [self adjustFrame];
}

- (void)adjustFrame {
    if (_imageView.image == nil) return;
    
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    CGFloat minScale = boundsWidth / imageWidth;
    if (minScale > 1) {
        minScale = 1.0;
    }
    CGFloat maxScale = 2.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    if (imageFrame.size.height < boundsHeight) {
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
    } else {
        imageFrame.origin.y = 0;
    }
    
    if (_photo.isFirstShow) {
        _photo.isFirstShow = NO;
        _imageView.frame = [_photo.sourceImageView convertRect:_photo.sourceImageView.bounds toView:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
            _imageView.frame = imageFrame;
        } completion:^(BOOL finished) {
            _photo.sourceImageView.image = _photo.placeholderImage;
            [self photoStartLoad];
        }];
    } else {
        _imageView.frame = imageFrame;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    _isDoubleTap = NO;
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}
- (void)hide {
    if (_isDoubleTap) return;
    
    [_photoLoadingView removeFromSuperview];
    self.contentOffset = CGPointZero;
    
    _photo.sourceImageView.image = nil;
    
    CGFloat duration = 0.15;
    if (_photo.sourceImageView.clipsToBounds) {
        [self performSelector:@selector(reset) withObject:nil afterDelay:duration];
    }
    
    [UIView animateWithDuration:duration + 0.1 animations:^{
        _imageView.frame = [_photo.sourceImageView convertRect:_photo.sourceImageView.bounds toView:nil];
        _imageView.alpha = 0;
        
        if (_imageView.image.images) {
            _imageView.image = _imageView.image.images[0];
        }
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
            [self.photoViewDelegate photoViewSingleTap:self];
        }
    } completion:^(BOOL finished) {
        _photo.sourceImageView.image = _photo.placeholderImage;
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
            [self.photoViewDelegate photoViewDidEndZoom:self];
        }
    }];
}

- (void)reset {
    _imageView.image = _photo.capturedImage;
    _imageView.contentMode = UIViewContentModeScaleToFill;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    _isDoubleTap = YES;
    
    CGPoint touchPoint = [tap locationInView:self];
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

- (void)dealloc {
    [_imageView sd_setImageWithURL:[NSURL URLWithString:@"file:///abc"]];
}
@end
