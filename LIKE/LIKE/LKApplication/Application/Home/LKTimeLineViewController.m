//
//  LKTimeLineViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTimeLineViewController.h"
#import "LKFeedViewController.h"
#import "LKFollowingViewController.h"

@interface LKTimeLineViewController ()

LC_PROPERTY(strong) LKFeedViewController *feedViewController;
LC_PROPERTY(strong) LKFollowingViewController *followingViewController;
LC_PROPERTY(weak) LCUIViewController *currentViewController;

@end

@implementation LKTimeLineViewController

- (void)buildUI {
    [self buildNavigationBar];
    [self buildViewController];
}

- (void)buildViewController {
    self.feedViewController = [LKFeedViewController viewController];
    self.followingViewController = [LKFollowingViewController viewController];
    
    [self addChildViewController:self.feedViewController];
    [self addChildViewController:self.followingViewController];
    
    self.currentViewController = self.feedViewController;
    self.view.ADD(self.currentViewController.view);
}

- (void)buildNavigationBar {
    // Bar item.
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image: [[UIImage imageNamed:@"CollectionIcon.png" useCache:YES] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]] selectImage:nil];
    
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
    //    self.titleView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"HomeLikeIcon.png" useCache:YES]];
    self.titleView = (UIView *)titleBtn;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        @weakly(self);
        
        LC_FAST_ANIMATIONS_F(0.25, ^{
            
            @normally(self);
            
            self.currentViewController.view.alpha = 0;
            
        }, ^(BOOL finished){
            
            @normally(self);
            
            [self.currentViewController.view removeFromSuperview];
            if (self.currentViewController == self.feedViewController) {
                self.currentViewController = self.followingViewController;
            } else {
                self.currentViewController = self.feedViewController;
            }
            self.view.ADD(self.currentViewController.view);
            
            LC_FAST_ANIMATIONS(0.25, ^{
                self.currentViewController.view.alpha = 1;
            });
            
        });
    }
}

@end
