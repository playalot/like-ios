//
//  LKWelcome.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/24.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKWelcome.h"
#import "LKLoginViewController.h"

@implementation LKWelcome

+(void) welcome
{
    if (!LKLocalUser.singleton.isLogin) {
    
        LCUIImageView * imageView = LCUIImageView.view;
        imageView.image = [LKWelcome image];
        imageView.viewFrameWidth = LC_DEVICE_WIDTH;
        imageView.viewFrameHeight = LC_DEVICE_HEIGHT + 20;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [LC_KEYWINDOW addSubview:imageView];
        
        [LCUIApplication presentViewController:LKLoginViewController.viewController];

        // UIViewAnimationOptionCurveLinear 动画匀速执行，默认值
        [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];

        }];
    }
}

-(void) openLoginViewController
{
}

+(UIImage *) image
{
    UIImage * image = nil;
    
    if (UI_IS_IPHONE4) {
        
        image = [UIImage imageNamed:@"960.jpg" useCache:NO];
    }
    else if (UI_IS_IPHONE5){
        
        image = [UIImage imageNamed:@"1136.jpg" useCache:NO];
    }
    else if (UI_IS_IPHONE6){
        
        image = [UIImage imageNamed:@"1334.jpg" useCache:NO];
    }
    else if(UI_IS_IPHONE6PLUS){
        
        image = [UIImage imageNamed:@"2208.jpg" useCache:NO];
    }
    else if (UI_IS_IPADMINI){
        
        image = [UIImage imageNamed:@"1024.jpg" useCache:NO];
    }
    else if(UI_IS_IPADAIR2){
        
        image = [UIImage imageNamed:@"2048.jpg" useCache:NO];
    }
    
    return image;
}

@end
