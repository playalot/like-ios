//
//  LC_UINavigationController.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

// Application default config
#define LC_UINAVIGATIONBAR_DEFAULT_TITLE_COLOR        [UIColor whiteColor]//LC_RGB(251, 255, 246)
#define LC_UINAVIGATIONBAR_DEFAULT_TITLE_SHADOW_COLOR LC_RGBA(0, 0, 0, 0)
#define LC_UINAVIGATIONBAR_DEFAULT_IMAGE_IOS7_BEFORE  nil//[UIImage imageNamed:@"LC_navbar_bg.png" useCache:YES]
#define LC_UINAVIGATIONBAR_DEFAULT_IMAGE_IOS7_LATER   nil//[UIImage imageNamed:@"LC_ios7_navbar_bg.png" useCache:YES]

#define LC_UINAVIGATION_BAR_DEFAULT_BUTTON_TITLE_COLOR        [UIColor darkGrayColor]


LC_BLOCK(id <UIViewControllerAnimatedTransitioning>, LCAnimationHandler, (UINavigationControllerOperation operation, UIViewController * fromVC, UIViewController * toVC));


@interface LCUINavigationController : UINavigationController <UIGestureRecognizerDelegate,UINavigationControllerDelegate>

LC_PROPERTY(copy) LCAnimationHandler animationHandler;

-(void) setBarTitleTextColor:(UIColor *)color shadowColor:(UIColor *)shadowColor;
-(void) setBarBackgroundImage:(UIImage *)image;

@end
