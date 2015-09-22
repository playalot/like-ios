//
//  AppDelegate.h
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKTabBarController.h"
#import "LKHomeViewController.h"
#import "LKCameraViewController.h"
#import "LKNotificationView.h"
#import "LKSearchViewController.h"
#import "LKNotificationViewController.h"
#import "LKUserCenterViewController.h"
#import "LKFollowingFeedViewController.h"
#import "LKHomeFeedViewController.h"
#import "LKMainFeedViewController.h"
#import "LKGroupViewController.h"
#import "LKCameraRollViewController.h"

LC_NOTIFICATION_SET(LKSessionError);

@interface AppDelegate : LCUIApplication

LC_PROPERTY(strong) LKTabBarController *tabBarController;
LC_PROPERTY(strong) LKMainFeedViewController *mainFeedViewController;
LC_PROPERTY(strong) LKHomeViewController *homeViewController;
LC_PROPERTY(strong) LKSearchViewController *searchViewController;
LC_PROPERTY(strong) LKCameraRollViewController *cameraRollViewController;
LC_PROPERTY(strong) LKNotificationViewController *notificationViewController;
LC_PROPERTY(strong) LKUserCenterViewController *userCenterViewController;
LC_PROPERTY(strong) LKGroupViewController *groupViewController;
LC_PROPERTY(strong) UIViewController * none;

@end

