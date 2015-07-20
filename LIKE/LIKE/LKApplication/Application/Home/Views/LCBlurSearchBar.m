//
//  LCBlurSearchBar.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCBlurSearchBar.h"
#import "FXBlurView.h"
#import "AppDelegate.h"

@implementation LCBlurSearchBar

-(instancetype) init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 40)]) {
        
        [self buildUI];
    }
    
    return self;
}

-(void) buildUI
{
    FXBlurView * blur = [[FXBlurView alloc] initWithFrame:CGRectMake(5, 5, self.viewFrameWidth - 10, 30)];
    blur.cornerRadius = 4;
    blur.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
    blur.blurRadius = 10;
    blur.layer.masksToBounds = YES;
    self.ADD(blur);
}

@end
