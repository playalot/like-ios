//
//  LKNotificationHeader.m
//  LIKE
//
//  Created by huangweifeng on 9/14/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationHeader.h"
#import "FXBlurView.h"
#import "LKLoginViewController.h"
#import "UIImageView+WebCache.h"

@implementation LKNotificationHeader

- (instancetype)initWithCGSize:(CGSize)size
{
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        [self buildUI];
    }
    
    return self;
}

- (void) buildUI {
    
    self.backgroundView = LCUIImageView.view;
    self.backgroundView.frame = self.bounds;
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundView.userInteractionEnabled = YES;
    self.backgroundView.autoMask = YES;
    self.ADD(self.backgroundView);
    
    if (IOS8_OR_LATER) {
        
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.blurView.frame = CGRectMake(5, 5, self.viewFrameWidth - 10, 30);
        self.blurView.cornerRadius = 4;
        self.blurView.layer.shouldRasterize = NO;
        self.blurView.layer.rasterizationScale = 1;
        
        UIView * view = UIView.view.COLOR([[UIColor whiteColor] colorWithAlphaComponent:0.15]);
        view.frame = self.blurView.bounds;
        ((UIVisualEffectView *)self.blurView).contentView.ADD(view);
    }
    else{
        
        self.blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(5, 5, self.viewFrameWidth - 10, 30)];
        ((FXBlurView *)self.blurView).blurRadius = 10;
        self.blurView.cornerRadius = 4;
    }
    
    self.blurView.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
    self.blurView.layer.masksToBounds = YES;
    self.ADD(self.blurView);
    
    self.headImageView = LCUIImageView.view;
    self.headImageView.viewFrameHeight = 50;
    self.headImageView.viewFrameWidth = 50;
    self.headImageView.viewFrameX = 40;
    self.headImageView.viewFrameY = (self.viewFrameHeight - 40) / 2 - self.headImageView.viewMidHeight + 40;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headImageView.cornerRadius =  self.headImageView.viewMidHeight;
    self.headImageView.borderWidth = 2;
    self.headImageView.borderColor = [UIColor whiteColor];
    self.headImageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    self.headImageView.userInteractionEnabled = YES;
//    [self.headImageView addTapGestureRecognizer:self selector:@selector(userHeadTapAction)];
    self.ADD(self.headImageView);
    
    self.nameLabel = LCUILabel.view;
    self.nameLabel.viewFrameX = self.headImageView.viewRightX + 20;
    self.nameLabel.viewFrameY = self.headImageView.viewFrameY;
    self.nameLabel.viewFrameWidth = self.viewFrameWidth - self.nameLabel.viewFrameX - 20;
    self.nameLabel.viewFrameHeight = self.headImageView.viewFrameHeight;
    self.nameLabel.font = LK_FONT_B(13);
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.text = [NSString stringWithFormat:@"%@\n%@ likes",LKLocalUser.singleton.user.name, @(LKLocalUser.singleton.user.likes.integerValue)];
    self.ADD(self.nameLabel);
}

@end
