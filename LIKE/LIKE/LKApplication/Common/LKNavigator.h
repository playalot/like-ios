//
//  LKNavigator.h
//  LIKE
//
//  Created by huangweifeng on 9/27/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKCameraViewController.h"
#import "LKSearchViewController.h"
#import "LKTabBarController.h"
#import "LKNotificationViewController.h"
#import "LKUserCenterViewController.h"
#import "LKFollowingFeedViewController.h"
#import "LKMainFeedViewController.h"
#import "LKGroupViewController.h"
#import "LKCameraRollViewController.h"
#import "LKGuestFeedViewController.h"

@interface LKNavigator : NSObject

LC_PROPERTY(strong) LKTabBarController *tabBarController;
LC_PROPERTY(strong) LKMainFeedViewController *mainFeedViewController;
LC_PROPERTY(strong) LKSearchViewController *searchViewController;
LC_PROPERTY(strong) LKCameraRollViewController *cameraRollViewController;
LC_PROPERTY(strong) LKNotificationViewController *notificationViewController;
LC_PROPERTY(strong) LKUserCenterViewController *userCenterViewController;
LC_PROPERTY(strong) LKGroupViewController *groupViewController;

+ (instancetype)navigator;

LC_PROPERTY(strong) LCUINavigationController *mainViewController;

- (void)popToRootViewController:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)popViewController:(BOOL)animated;

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)flag;

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion;

- (void)openLoginViewController;

- (void)launchGuestMode;

- (void)launchMasterMode;

- (void)dismissAllViewControllers;

- (void)bindBadgeForItemIndex:(NSInteger)index badgeCount:(NSInteger)count;

@end
