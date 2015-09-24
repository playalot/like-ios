//
//  LKMainFeedViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKMainFeedViewController.h"
#import "LKHomeFeedViewController.h"
#import "LKFollowingFeedViewController.h"


@interface LKMainFeedViewController ()

LC_PROPERTY(strong) LKHomeFeedViewController *feedViewController;
LC_PROPERTY(strong) LKFollowingFeedViewController *followingViewController;
LC_PROPERTY(weak) LCUIViewController *currentViewController;

@end

@implementation LKMainFeedViewController

- (void)buildUI {
    [self buildNavigationBar];
    [self buildViewController];
}

- (void)buildViewController {
    self.feedViewController = [LKHomeFeedViewController viewController];
    self.followingViewController = [LKFollowingFeedViewController viewController];
    
    [self addChildViewController:self.feedViewController];
    [self addChildViewController:self.followingViewController];
    
    self.currentViewController = self.feedViewController;
    self.view.ADD(self.currentViewController.view);
}

- (void)buildNavigationBar {
    // Bar item.
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[[UIImage imageNamed:@"Favor_selected.png" useCache:YES] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]] selectImage:nil];
    
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
    self.titleView = (UIView *)titleBtn;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    LCUIButton *left = (LCUIButton *)self.navigationItem.leftBarButtonItem.customView;
    left.showsTouchWhenHighlighted = YES;
    UIView *title = self.titleView;
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        @weakly(self);
        LC_FAST_ANIMATIONS_F(0.25, ^{
            
            @normally(self);
            self.currentViewController.view.alpha = 0;
            left.alpha = 0;
            title.alpha = 0;
            
        }, ^(BOOL finished) {
            
            @normally(self);
            [self.currentViewController.view removeFromSuperview];
            if (self.currentViewController == self.feedViewController) {
                self.currentViewController = self.followingViewController;
                [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[[UIImage imageNamed:@"Favor_normal.png" useCache:YES] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]] selectImage:nil];

                if (self.titleView) {
                    
                    [self.titleView removeFromSuperview];
                    
                    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
                    titleBtn.title = LC_LO(@"关注的人");
                    titleBtn.titleFont = LK_FONT_B(16);
                    self.titleView = (UIView *)titleBtn;
                }
            } else {
                self.currentViewController = self.feedViewController;
                [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[[UIImage imageNamed:@"Favor_selected.png" useCache:YES] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]] selectImage:nil];
                
                if (self.titleView) {
                    
                    [self.titleView removeFromSuperview];
                    
                    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
                    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
                    self.titleView = (UIView *)titleBtn;
                }
            }
            self.view.ADD(self.currentViewController.view);
            
            LC_FAST_ANIMATIONS(0.25, ^{
                self.currentViewController.view.alpha = 1;
                left.alpha = 1;
                title.alpha = 1;
            });
            
        });
    }
}

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal) {
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
}

@end
