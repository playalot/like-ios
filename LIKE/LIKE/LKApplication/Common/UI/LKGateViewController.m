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
    self.logoImageView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"like_logo" useCache:NO]];
    self.logoImageView.viewFrameX = (self.view.viewFrameWidth - self.logoImageView.viewFrameWidth) / 2;
    self.logoImageView.viewFrameY = 68;
    self.view.ADD(self.logoImageView);
    
    self.introImageView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"intro_logo" useCache:NO]];
    self.introImageView.viewFrameX = (self.view.viewFrameWidth - self.introImageView.viewFrameWidth) / 2;
    self.introImageView.viewFrameY = CGRectGetMaxY(self.logoImageView.frame) + 148;
    self.view.ADD(self.introImageView);
    
    UIImage *getInImage = [UIImage imageNamed:@"get_in_like" useCache:YES];
    self.getInButton = LCUIButton.view;
    self.getInButton.viewFrameWidth = getInImage.size.width;
    self.getInButton.viewFrameHeight = getInImage.size.height;
    self.getInButton.viewFrameX = (self.view.viewFrameWidth - self.getInButton.viewFrameWidth) / 2;
    self.getInButton.viewFrameY = self.view.viewFrameHeight - getInImage.size.height - 50;
    [self.getInButton setImage:getInImage forState:UIControlStateNormal];
    [self.getInButton setImage:getInImage forState:UIControlStateSelected];
    self.getInButton.selected = NO;
    self.getInButton.showsTouchWhenHighlighted = YES;
    [self.getInButton addTarget:self action:@selector(getIn) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.getInButton);
}

- (void)getIn {
    
    LC_FAST_ANIMATIONS_F(0.2, ^{
        self.view.alpha = 0;
    }, ^(BOOL finished){
        if (![self.navigationController popViewControllerAnimated:NO]) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    });
}

@end
