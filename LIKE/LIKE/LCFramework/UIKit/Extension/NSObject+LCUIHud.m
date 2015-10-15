//
//  NSObject+Hud.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-30.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "NSObject+LCUIHud.h"

@implementation NSObject (LCUIHud)

- (LCUIHud *)showMessageHud:(NSString *)message
{
	return [LCUIHudCenter.singleton showMessageHud:message inView:[self $getView]];
}

- (LCUIHud *)showSuccessHud:(NSString *)message
{
	return [LCUIHudCenter.singleton showSuccessHud:message inView:[self $getView]];
}

- (LCUIHud *)showFailureHud:(NSString *)message
{
	return [LCUIHudCenter.singleton showFailureHud:message inView:[self $getView]];
}

- (LCUIHud *)showLoadingHud:(NSString *)message
{
	return [LCUIHudCenter.singleton showLoadingHud:message inView:[self $getView]];
}

- (LCUIHud *)showProgressHud:(NSString *)message
{
	return [LCUIHudCenter.singleton showProgressHud:message inView:[self $getView]];
}

-(UIView *) $getView
{
    UIView * container = nil;
    
    if ([self isKindOfClass:[UIView class]]){
        
        container = (UIView *)self;
    }
    else if ([self isKindOfClass:[UIViewController class]]){
        
        container = ((UIViewController *)self).view;
    }
    else{
        container = LC_KEYWINDOW;
    }
    
    return container;
}

-(LCUIHudShow) SHOW_MESSAGE
{
    LCUIHudShow block = ^ LCUIHud * (NSString * message){
        
        return [self showMessageHud:message];
    };
    
    return block;
}

-(LCUIHudShow) SHOW_SUCCESS
{
    LCUIHudShow block = ^ LCUIHud * (NSString * message){
        
        return [self showSuccessHud:message];
    };
    
    return block;
}

-(LCUIHudShow) SHOW_FAILED
{
    LCUIHudShow block = ^ LCUIHud * (NSString * message){
        
        return [self showFailureHud:message];
    };
    
    return block;
}

-(LCUIHudShow) SHOW_LOADING
{
    LCUIHudShow block = ^ LCUIHud * (NSString * message){
        
        return [self showLoadingHud:message];
    };
    
    return block;
}

-(LCUIHudShow) SHOW_PREOGRESS
{
    LCUIHudShow block = ^ LCUIHud * (NSString * message){
        
        return [self showProgressHud:message];
    };
    
    return block;
}

@end
