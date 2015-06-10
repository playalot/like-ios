//
//  LC_HudCenter.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-30.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface LCUIHud : MBProgressHUD

-(void) hide;

/*
 
    Thanks for MBProgressHUD.
 
 */

@end

@interface LCUIHudCenter : NSObject

+ (void)setDefaultMessageIcon:(UIImage *)image;
+ (void)setDefaultSuccessIcon:(UIImage *)image;
+ (void)setDefaultFailureIcon:(UIImage *)image;
+ (void)setDefaultBubble:(UIImage *)image;


- (LCUIHud *)showMessageHud:(NSString *)message inView:(UIView *)view;
- (LCUIHud *)showSuccessHud:(NSString *)message inView:(UIView *)view;
- (LCUIHud *)showFailureHud:(NSString *)message inView:(UIView *)view;
- (LCUIHud *)showLoadingHud:(NSString *)message inView:(UIView *)view;
- (LCUIHud *)showProgressHud:(NSString *)message inView:(UIView *)view;

@end
