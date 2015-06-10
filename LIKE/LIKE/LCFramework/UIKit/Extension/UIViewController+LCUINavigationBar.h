//
//  UIViewController+UINavigationBar.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-16.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//


typedef NS_ENUM(NSInteger ,LCUINavigationBarButtonType)
{
    LCUINavigationBarButtonTypeLeft,
    LCUINavigationBarButtonTypeRight,
};

@interface UIViewController (LCUINavigationBar)

+ (instancetype)viewController;

#define LC_HANDLE_NAVIGATION_BUTTON(type) -(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type

// Overwrite
-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type;

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setNavigationBarButton:(LCUINavigationBarButtonType)type image:(UIImage *)image selectImage:(UIImage *)selectImage;
- (void)setNavigationBarButton:(LCUINavigationBarButtonType)type title:(NSString *)title titleColor:(UIColor *)titleColor;
- (void)setNavigationBarButton:(LCUINavigationBarButtonType)type customView:(UIView *)view;

- (void)didLeftBarButtonTouched;
- (void)didRightBarButtonTouched;

@end
