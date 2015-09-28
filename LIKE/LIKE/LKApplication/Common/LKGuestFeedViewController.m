//
//  LKGuestFeedViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/27/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKGuestFeedViewController.h"
#import "LKHomeFeedViewController.h"

@interface LKGuestFeedViewController ()

LC_PROPERTY(strong) UINavigationBar *navigationBar;
LC_PROPERTY(strong) LKHomeFeedViewController *homeFeedViewController;

@end

@implementation LKGuestFeedViewController

- (void)buildUI {
    [self buildNavigationBar];
    self.homeFeedViewController = [LKHomeFeedViewController viewController];
    [self addChildViewController:self.homeFeedViewController];
    self.homeFeedViewController.view.viewFrameY = CGRectGetMaxY(self.navigationBar.frame);
    self.view.ADD(self.homeFeedViewController.view);
}

- (void)buildNavigationBar {
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 64)];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    self.view.ADD(self.navigationBar);
    
    titleBtn.viewFrameX = (self.navigationBar.viewFrameWidth - titleBtn.viewFrameWidth) / 2;
    titleBtn.viewFrameY = (self.navigationBar.viewFrameHeight - titleBtn.viewFrameHeight) / 2;
    self.navigationBar.ADD(titleBtn);
}

@end
