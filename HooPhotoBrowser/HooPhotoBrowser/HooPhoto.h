//
//  HooPhoto.h
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HooPhoto : NSObject

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIImageView *sourceImageView;

@property (nonatomic, strong, readonly) UIImage *placeholderImage;

@property (nonatomic, strong, readonly) UIImage *capturedImage;

@property (nonatomic, assign) BOOL isFirstShow;

@property (nonatomic, assign) BOOL isSave;

@property (nonatomic, assign) NSInteger index;

@end
