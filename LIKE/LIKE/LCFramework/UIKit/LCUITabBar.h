//
//  LC_UITableBar.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-11.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

#pragma mark -

@interface LCUITabBarItem : LCUIButton

+(LCUITabBarItem *) tabBarItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage;

-(void) setHighlighted:(BOOL)highlighted;

@end

#pragma mark -

@interface LCUITabBar : LCUIImageView

LC_PROPERTY(strong) NSArray * items;
LC_PROPERTY(assign) NSInteger selectedIndex;

-(LCUITabBar *) initWithTabBarItems:(NSArray *)items;

@end
