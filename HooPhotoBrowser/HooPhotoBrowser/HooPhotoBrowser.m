//
//  HooPhotoBrowser.m
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import "HooPhotoBrowser.h"
#import "HooPhoto.h"
#import "HooPhotoToolBar.h"
#import "HooPhotoView.h"
#import "UIImageView+WebCache.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface HooPhotoBrowser ()<UIScrollViewDelegate, HooPhotoViewDelegate> {
    
    NSMutableSet *_visiblePhotoViews;
    
    NSMutableSet *_reusablePhotoViews;
    
    BOOL _statusBarHiddenInited;
}

@property (nonatomic, strong) HooPhotoToolBar *toolbar;

@property (nonatomic, strong) UIScrollView *photoScrollView;

@end

@implementation HooPhotoBrowser

- (HooPhotoToolBar *)toolbar {
    if (!_toolbar) {
        CGFloat barHeight = 44;
        CGFloat barY = self.view.frame.size.height - barHeight;
        _toolbar = [[HooPhotoToolBar alloc] init];
        _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _toolbar.photos = _photos;
        
        [self updateTollbarState];
    }
    return _toolbar;
}

- (UIScrollView *)photoScrollView {
    if (!_photoScrollView) {
        CGRect frame = self.view.bounds;
        frame.origin.x -= kPadding;
        frame.size.width += (2 * kPadding);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.delegate = self;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
        _photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
    }
    return _photoScrollView;
}

- (void)setPhotos:(NSArray *)photos {
    if (!photos) return;
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
    for (int i = 0; i < _photos.count; i++) {
        HooPhoto *photo = _photos[i];
        photo.index = i;
        photo.isFirstShow = i == _currentPhotoIndex;
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex {
    _currentPhotoIndex = currentPhotoIndex;
    
    for (int i = 0; i < _photos.count; i++) {
        HooPhoto *photo = _photos[i];
        photo.isFirstShow = i == currentPhotoIndex;
    }
    
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

#pragma mark - Lifecycle
- (void)loadView
{
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    [self prefersStatusBarHidden];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.photoScrollView];

    [self.view addSubview:self.toolbar];
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}

- (void)showPhotos {

    if (!_photos.count) {
        return;
    }
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
    int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
    int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = (int)_photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = (int)_photos.count - 1;
    
    NSInteger photoViewIndex;
    for (HooPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:(int)index];
        }
    }
}

- (void)showPhotoViewAtIndex:(int)index {
    HooPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) {
        photoView = [[HooPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }

    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    if (_photos.count) {
        
        HooPhoto *photo = _photos[index];
        photoView.frame = photoViewFrame;
        photoView.photo = photo;
        
        [_visiblePhotoViews addObject:photoView];
        [_photoScrollView addSubview:photoView];
        
        [self loadImageNearIndex:index];
    }
}

- (void)loadImageNearIndex:(int)index {
    if (index > 0) {
        HooPhoto *photo = _photos[index - 1];
        
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:SDWebImageRetryFailed | SDWebImageLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
        }];
    }
    
    if (index < _photos.count - 1) {
        HooPhoto *photo = _photos[index + 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:photo.url options:SDWebImageRetryFailed | SDWebImageLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
        }];
    }
}

- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (HooPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            return YES;
        }
    }
    return  NO;
}

- (HooPhotoView *)dequeueReusablePhotoView {
    HooPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    return photoView;
}

- (void)updateTollbarState {
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    [self updateTollbarState];
}

#pragma mark - MJPhotoViewDelegate
- (void)photoViewSingleTap:(HooPhotoView *)photoView
{
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    
    [_toolbar removeFromSuperview];
}

- (void)photoViewDidEndZoom:(HooPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)photoViewImageFinishLoad:(HooPhotoView *)photoView
{
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

@end
