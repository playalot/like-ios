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
//    self.titleView = (UIView *)titleBtn;
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 64)];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    self.view.ADD(self.navigationBar);
    
//    UINavigationItem *titleNavItem = [[UINavigationItem alloc] init];
//    titleNavItem.titleView = titleBtn;
    self.navigationBar.topItem.titleView = titleBtn;
}

@end
