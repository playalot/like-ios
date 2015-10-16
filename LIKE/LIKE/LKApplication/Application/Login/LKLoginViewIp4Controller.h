//
//  LKLoginViewIp4Controller.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/16.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewController.h"

@protocol LKLoginViewIp4ControllerDelegate;

@interface LKLoginViewIp4Controller : LCUITableViewController

LC_PROPERTY(weak) id<LKLoginViewIp4ControllerDelegate> delegate;

/**
 *  当前window背景虚化
 */
-(void) currentWindowBlur:(UIViewController *)viewController;
/**
 *  是否需要登录
 */
+ (BOOL)needLoginOnViewController:(UIViewController *)viewController;

@end

@protocol LKLoginViewIp4ControllerDelegate <NSObject>

- (void)didLoginIp4Succeeded:(NSDictionary *)userInfo;

- (void)didLoginIp4Failed;

- (void)didGoToIp4GuestFeed;

@end
