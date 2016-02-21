//
//  HooPhotoBrowser.h
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HooPhotoBrowser;

@protocol HooPhotoBrowserDelegate <NSObject>
@optional

- (void)photoBrowser:(HooPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

@end

@interface HooPhotoBrowser : UIViewController

@property (nonatomic, weak) id<HooPhotoBrowserDelegate> delegate;

@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, assign) NSUInteger currentPhotoIndex;

- (void)show;

@end
