//
//  LKTabBarController.h
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "RDVTabBarController.h"

@class LKAssistiveTouchButton;

@interface LKTabBarController : RDVTabBarController
/**
 *  是否正在加载
 */
LC_PROPERTY(assign) BOOL loading;
LC_PROPERTY(strong) LKAssistiveTouchButton * assistiveTouchButton;

-(instancetype) initWithViewControllers:(NSArray *)viewControllers;

-(void) showBar;
-(void) hideBar;

/**
 *  push控制器的时候隐藏bottomBar
 */
+(UIViewController *) hiddenBottomBarWhenPushed:(UIViewController *)viewController;

@end
