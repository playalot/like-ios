//
//  LKGateViewController.m
//  LIKE
//
//  Created by huangweifeng on 10/4/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKGateViewController.h"
#import "LKColor.h"

@interface LKGateViewController ()

LC_PROPERTY(strong) LCUIImageView *logoImageView;
LC_PROPERTY(strong) LCUIImageView *introImageView;
LC_PROPERTY(strong) LCUIButton *getInButton;

@end

@implementation LKGateViewController

- (void)buildUI {
    self.view.backgroundColor = [LKColor color];
    if (UI_IS_IPHONE4) {
        self.logoImageView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"like_logo_ip4" useCache:NO]];
        self.logoImageView.viewFrameY = 72;
    } else {
        self.logoImageView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"like_logo" useCache:NO]];
        self.logoImageView.viewFrameY = 99;
    }
    self.logoImageView.viewFrameX = (self.view.viewFrameWidth - self.logoImageView.viewFrameWidth) / 2;
    self.view.ADD(self.logoImageView);
    
    if (UI_IS_IPHONE4) {
        self.introImageView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"intro_logo_ip4" useCache:NO]];
        self.introImageView.viewFrameY = CGRectGetMaxY(self.logoImageView.frame) + 51;
    } else {
        self.introImageView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"intro_logo" useCache:NO]];
        self.introImageView.viewFrameY = CGRectGetMaxY(self.logoImageView.frame) + 60;
    }
    self.introImageView.viewFrameX = (self.view.viewFrameWidth - self.introImageView.viewFrameWidth) / 2;
    self.view.ADD(self.introImageView);
    
    UIImage *getInImage = [UIImage imageNamed:@"get_in_like" useCache:YES];
    self.getInButton = LCUIButton.view;
    self.getInButton.viewFrameWidth = getInImage.size.width;
    self.getInButton.viewFrameHeight = getInImage.size.height;
    self.getInButton.viewFrameX = (self.view.viewFrameWidth - self.getInButton.viewFrameWidth) / 2;
    if (UI_IS_IPHONE4) {
        self.getInButton.viewFrameY = self.introImageView.viewBottomY + 169;
        self.getInButton.titleFont = LK_FONT(13);
    } else {
        self.getInButton.viewFrameY = self.view.viewFrameHeight - getInImage.size.height - 102;
        self.getInButton.titleFont = LK_FONT(18);
    }
    [self.getInButton setBackgroundImage:getInImage forState:UIControlStateNormal];
    [self.getInButton setBackgroundImage:getInImage forState:UIControlStateSelected];
    self.getInButton.selected = NO;
    self.getInButton.showsTouchWhenHighlighted = YES;
    self.getInButton.title = LC_LO(@"进入like");
    self.getInButton.titleColor = LKColor.color;
    [self.getInButton addTarget:self action:@selector(getIn) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.getInButton);
}

- (void)getIn {
    if (![self.navigationController popViewControllerAnimated:NO]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
