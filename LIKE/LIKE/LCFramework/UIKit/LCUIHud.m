//
//  LC_HudCenter.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-30.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIHud.h"

#define DEFAULT_TIMEOUT_SECONDS 2

@implementation LCUIHud

-(void) hide
{
    [self hide:YES];
}

@end

@interface LCUIHudCenter ()

LC_PROPERTY(strong) UIImage * bubble;
LC_PROPERTY(strong) UIImage * messageIcon;
LC_PROPERTY(strong) UIImage * successIcon;
LC_PROPERTY(strong) UIImage * failureIcon;


@end

@implementation LCUIHudCenter

+ (void)setDefaultMessageIcon:(UIImage *)image
{
    LCUIHudCenter.singleton.messageIcon = image;
}

+ (void)setDefaultSuccessIcon:(UIImage *)image
{
    LCUIHudCenter.singleton.successIcon = image;
}

+ (void)setDefaultFailureIcon:(UIImage *)image
{
    LCUIHudCenter.singleton.failureIcon = image;
}

+ (void)setDefaultBubble:(UIImage *)image
{
    LCUIHudCenter.singleton.bubble = image;
}

- (LCUIHud *)showMessageHud:(NSString *)message inView:(UIView *)view
{
    LCUIHud * hud = [LCUIHud showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabelText = message;
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    
    [hud hide:YES afterDelay:DEFAULT_TIMEOUT_SECONDS];
    
    if (self.messageIcon) {
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [LCUIImageView viewWithImage:self.messageIcon];
    }
    
    if (self.bubble) {
        hud.color = [UIColor colorWithPatternImage:self.bubble];
    }
    
    return hud;
}

- (LCUIHud *)showSuccessHud:(NSString *)message inView:(UIView *)view;
{
    LCUIHud * hud = [LCUIHud showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabelText = message;
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:DEFAULT_TIMEOUT_SECONDS];

    if (self.successIcon) {
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [LCUIImageView viewWithImage:self.successIcon];
    }
    
    if (self.bubble) {
        hud.color = [UIColor colorWithPatternImage:self.bubble];
    }
    
    return hud;
}

- (LCUIHud *)showFailureHud:(NSString *)message inView:(UIView *)view
{
    LCUIHud * hud = [LCUIHud showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabelText = message;
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:DEFAULT_TIMEOUT_SECONDS];

    if (self.failureIcon) {
        
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [LCUIImageView viewWithImage:self.failureIcon];
    }
    
    if (self.bubble) {
        hud.color = [UIColor colorWithPatternImage:self.bubble];
    }
    
    return hud;
}

- (LCUIHud *)showLoadingHud:(NSString *)message inView:(UIView *)view
{
    LCUIHud * hud = [LCUIHud showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabelText = message;
    hud.mode = MBProgressHUDModeIndeterminate;
    
    if (self.bubble) {
        hud.color = [UIColor colorWithPatternImage:self.bubble];
    }
    
    return hud;
}

- (LCUIHud *)showProgressHud:(NSString *)message inView:(UIView *)view
{
    LCUIHud * hud = [LCUIHud showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabelText = message;
    hud.mode = MBProgressHUDModeAnnularDeterminate;

    if (self.bubble) {
        hud.color = [UIColor colorWithPatternImage:self.bubble];
    }
    
    return hud;
}

@end