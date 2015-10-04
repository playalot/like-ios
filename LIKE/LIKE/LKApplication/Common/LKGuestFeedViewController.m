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
LC_PROPERTY(strong) LCUIView *tabBar;
LC_PROPERTY(strong) LCUIButton *loginButton;
LC_PROPERTY(strong) LCUIButton *registerButton;

@end

@implementation LKGuestFeedViewController

- (void)buildUI {
    [self buildNavigationBar];
    self.homeFeedViewController = [LKHomeFeedViewController viewController];
    [self addChildViewController:self.homeFeedViewController];
    self.homeFeedViewController.view.viewFrameY = CGRectGetMaxY(self.navigationBar.frame);
    self.view.ADD(self.homeFeedViewController.view);
    
    self.tabBar = [[LCUIView alloc] initWithFrame:CGRectMake(0, 0, self.view.viewFrameWidth, 49)];
    self.tabBar.viewFrameY = self.view.viewFrameHeight - self.tabBar.viewFrameHeight;
    self.tabBar.backgroundColor = [LKColor whiteColor];
    self.view.ADD(self.tabBar);
    
    self.loginButton = LCUIButton.view;
    self.loginButton.viewFrameX = 0;
    self.loginButton.viewFrameWidth = self.tabBar.viewFrameWidth / 2;
    self.loginButton.viewFrameHeight = self.tabBar.viewFrameHeight;
    self.loginButton.showsTouchWhenHighlighted = YES;
    self.loginButton.title = @"登录";
    self.loginButton.titleColor = [UIColor blackColor];
    self.loginButton.titleFont = [UIFont systemFontOfSize:14];
    [self.loginButton addTarget:self action:@selector(loginAndRegister) forControlEvents:UIControlEventTouchUpInside];
    self.tabBar.ADD(self.loginButton);
    
    self.registerButton = LCUIButton.view;
    self.registerButton.viewFrameX = CGRectGetMaxX(self.loginButton.frame);
    self.registerButton.viewFrameWidth = self.tabBar.viewFrameWidth / 2;
    self.registerButton.viewFrameHeight = self.tabBar.viewFrameHeight;
    self.registerButton.showsTouchWhenHighlighted = YES;
    self.registerButton.title = @"注册";
    self.registerButton.titleColor = [UIColor blackColor];
    self.registerButton.titleFont = [UIFont systemFontOfSize:14];
    [self.registerButton addTarget:self action:@selector(loginAndRegister) forControlEvents:UIControlEventTouchUpInside];
    self.tabBar.ADD(self.registerButton);
    
    LCUIView *line = LCUIView.view;
    line.backgroundColor = [UIColor colorWithRed:(151.0f/255.0f) green:(151.0f/255.0f) blue:(151.0f/255.0f) alpha:1];
    line.viewFrameHeight = 23;
    line.viewFrameWidth = 1;
    line.viewFrameX = (self.tabBar.viewFrameWidth - line.viewFrameWidth) / 2;
    line.viewFrameY = (self.tabBar.viewFrameHeight - line.viewFrameHeight) / 2;
    self.tabBar.ADD(line);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES animated:NO];
}

- (void)buildNavigationBar {
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, 64)];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    self.view.ADD(self.navigationBar);
    
    titleBtn.viewFrameX = (self.navigationBar.viewFrameWidth - titleBtn.viewFrameWidth) / 2;
    titleBtn.viewFrameY = 22 + (self.navigationBar.viewFrameHeight - 22 - titleBtn.viewFrameHeight) / 2;
    self.navigationBar.ADD(titleBtn);
}

- (void)loginAndRegister {
    [[LKNavigator navigator] openLoginViewController];
}

@end
