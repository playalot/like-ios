//
//  LC_UITableBarController.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-11.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>
#import "LCUITabBar.h"

@interface LCUITabBarController : UITabBarController

@property (nonatomic, retain) LCUITabBar * bar;
@property (nonatomic, assign) NSInteger lastSelectIndex;
@property (nonatomic, retain) NSArray * cantChangeViewControllerIndexs;

-(CGRect) tabBarControllerSetItemFrame:(LCUITabBarItem *)item;

-(void) handleTabBarItemClick:(LCUITabBarItem *)item;

@end
