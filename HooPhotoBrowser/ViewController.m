//
//  ViewController.m
//  HooPhotoBrowser
//
//  Created by hujianghua on 2/21/16.
//  Copyright © 2016 hujianghua. All rights reserved.
//

#import "ViewController.h"
#import "HooPhotoBrowser/HooPhotoBrowser.h"
#import "HooPhoto.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(50, 50, 200, 200);
    imageView.image = [UIImage imageNamed:@"uc_header_background.jpg"];
    [self.view addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToShow:)];
    tap.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tap];

}

- (void)tapToShow :(UITapGestureRecognizer *)tap {
        UIImageView *tapView = (UIImageView *)tap.view;
    NSArray *images = @[@"http://images.asiatravel.com/Hotel/8016/8016facade.jpg",
                        @"http://images.asiatravel.com/Hotel/8016/8016logo.jpg",
                        @"http://images.asiatravel.com/Hotel/8016/8016bathroom.jpg",
                        @"http://images.asiatravel.com/Hotel/8016/8016standard_room.jpg",
                        @"http://images.asiatravel.com/Hotel/8016/8016lobby-cafe.jpg",
                        @"http://images.asiatravel.com/Hotel/8016/8016lobby-reception.jpg",
                        @"http://images.asiatravel.com/Hotel/8016/8016pool.jpg"];
    NSInteger i = 0;
    NSMutableArray *pArray = [NSMutableArray array];
    for (NSString *url in images) {
        HooPhoto *photo = [[HooPhoto alloc] init];
        photo.url = [NSURL URLWithString:url];
        photo.index = i;
        photo.sourceImageView = tapView;
        [pArray addObject:photo];
        i++;
    }
    HooPhotoBrowser *photoBrowser = [[HooPhotoBrowser alloc] init];
    photoBrowser.currentPhotoIndex = 0;
    photoBrowser.photos = pArray;
    [photoBrowser show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
