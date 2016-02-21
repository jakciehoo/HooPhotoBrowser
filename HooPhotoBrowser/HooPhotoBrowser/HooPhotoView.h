//
//  HooPhotoView.h
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HooPhoto, HooPhotoView;

@protocol HooPhotoViewDelegate <NSObject>

- (void)photoViewImageFinishLoad:(HooPhotoView *)photoView;

- (void)photoViewSingleTap:(HooPhotoView *)photoView;

- (void)photoViewDidEndZoom:(HooPhotoView *)photoView;

@end

@interface HooPhotoView : UIScrollView

@property (nonatomic, strong) HooPhoto *photo;

@property (nonatomic, weak) id<HooPhotoViewDelegate> photoViewDelegate;

@end
