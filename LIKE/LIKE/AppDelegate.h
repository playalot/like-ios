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
#import "LKNotificationViewController.h"
#import "LKSearchViewController.h"


LC_NOTIFICATION_SET(LKSessionError);


@interface AppDelegate : LCUIApplication

LC_PROPERTY(strong) LKTabBarController * tabBarController;
LC_PROPERTY(strong) LKHomeViewController * homeViewController;
LC_PROPERTY(strong) LKSearchViewController * searchViewController;
LC_PROPERTY(strong) UIViewController * none;

@end

