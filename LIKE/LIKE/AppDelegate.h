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


LC_NOTIFICATION_SET(LKSessionError);


@interface AppDelegate : LCUIApplication

LC_PROPERTY(strong) LKTabBarController * tabBarController;

LC_PROPERTY(strong) LKHomeViewController * home;
LC_PROPERTY(strong) UIViewController * none;

@end

