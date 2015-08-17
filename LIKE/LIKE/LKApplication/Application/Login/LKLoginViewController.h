//
//  LKLoginViewController.h
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewController.h"

@interface LKLoginViewController : LCUITableViewController
/**
 *  当前window背景虚化
 */
-(void) currentWindowBlur:(UIViewController *)viewController;
/**
 *  是否需要登录
 */
+(BOOL) needLoginOnViewController:(UIViewController *)viewController;

@end
