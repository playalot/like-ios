//
//  LKTabBarController.m
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTabBarController.h"
#import "AppDelegate.h"
#import "LKLoginViewController.h"
#import "LKAssistiveTouchButton.h"
#import "MMMaterialDesignSpinner.h"
#import "LKCameraRollViewController.h"
#import "LKNotificationCount.h"

@interface LKTabBarController () <RDVTabBarControllerDelegate>

@end

@implementation LKTabBarController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏tabBar
    [self setTabBarHidden:NO];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [LKNotificationCount bindView:self.tabBar.items[2]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    if (self = [super init]) {
        self.viewControllers = viewControllers;
        self.delegate = self;
    }
    return self;
}

/**
 *  重写加载状态的set方法,设置按钮周围线条动画
 */
- (void)setLoading:(BOOL)loading {
    _loading = loading;
    MMMaterialDesignSpinner * tip = (MMMaterialDesignSpinner *)[self.assistiveTouchButton viewWithTag:100];

    if (loading) {
        // 旋转
        LC_FAST_ANIMATIONS_F(0.25, ^{
            tip.alpha = 0.8;
        }, ^(BOOL finished){
        
        });
    } else {
        [UIView animateWithDuration:1 animations:^{
            tip.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }
}

/**
 *  选中了相机按钮就会执行
 */
- (void)didTap {
    if(![LKLoginViewController needLoginOnViewController:self]){
        [LCUIApplication presentViewController:LC_UINAVIGATION([LKCameraRollViewController viewController]) animation:YES];
    }
}

- (void)touchDown:(UIView *)button {
    [@[button] pop_sequenceWithInterval:0 animations:^(UIView *circle, NSInteger index){

        button.pop_springBounciness = 10;
        button.pop_springSpeed = 12;
        button.pop_spring.pop_scaleXY = CGPointMake(1.2, 1.2);
        
    } completion:^(BOOL finished){
     

    }];
}

- (void)touchEnd:(UIView *)button
{
    [@[button] pop_sequenceWithInterval:0 animations:^(id object, NSInteger index) {

        button.pop_springBounciness = 10;
        button.pop_springSpeed = 12;
        button.pop_spring.pop_scaleXY = CGPointMake(1, 1);

    } completion:^(BOOL finished) {
        ;
    }];
}

-(void) showBar
{
    LC_FAST_ANIMATIONS(0.15, ^{
        
        self.assistiveTouchButton.alpha = 1;
    });
}

-(void) hideBar {
    LC_FAST_ANIMATIONS(0.15, ^{
        self.assistiveTouchButton.alpha = 0;
    });
}

#pragma mark - 

-(void) $setItemIcon:(NSString *)imageName superView:(UIView *)superView {
    LCUIImageView * icon = [LCUIImageView viewWithImage:[UIImage imageNamed:imageName useCache:YES]];
    icon.viewFrameX = superView.viewMidWidth - icon.viewMidWidth;
    icon.viewFrameY = superView.viewMidWidth - icon.viewMidHeight;
    superView.ADD(icon);
}

#pragma mark -

+(UIViewController *) hiddenBottomBarWhenPushed:(UIViewController *)viewController {    
    return viewController;
}

@end
