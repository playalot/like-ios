//
//  LC_UIAlertView.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-26.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIAlertView.h"

@interface LCUIAlertView () <UIAlertViewDelegate>

@end

@implementation LCUIAlertView

- (instancetype) init
{
    LC_SUPER_INIT({
        
        self.delegate = self;
    });
}

-(void) setDID_TOUCH:(LCUIAlertViewDidTouchedBlock)DID_TOUCH
{
    self.delegate = self;
    _DID_TOUCH = DID_TOUCH;
}

-(LCUIAlertViewParameterString) MESSAGE
{
    LCUIAlertViewParameterString block = ^ id (NSString * message){
        
        self.message = message;
        
        return self;
    };
    
    return block;
}

-(LCUIAlertViewParameterString) TITLE
{
    LCUIAlertViewParameterString block = ^ id (NSString * title){
        
        self.title = title;
        
        return self;
    };
    
    return block;
}

-(LCUIAlertViewParameterString) CANCEL
{
    LCUIAlertViewParameterString block = ^ id (NSString * cancel){
        
        if (cancel) {
            [self addButtonWithTitle:cancel];
        }
        
        return self;
    };
    
    return block;
}

-(LCUIAlertViewParameterString) OTHER
{
    LCUIAlertViewParameterString block = ^ id (NSString * other){
        
        if (other) {
            [self addButtonWithTitle:other];
        }
        
        return self;
    };
    
    return block;
}

-(LCUIAlertViewParameterNone) SHOW
{
    LCUIAlertViewParameterNone block = ^ id (){
        
        [self show];
        return self;
    };
    
    return block;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.DID_TOUCH) {
        self.DID_TOUCH(buttonIndex);
    }
}

+(instancetype) showWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle didTouchedBlock:(LCUIAlertViewDidTouchedBlock)didTouchedBlock
{
    LCUIAlertView * alertView = LCUIAlertView.VIEW.MESSAGE(message).TITLE(title).CANCEL(cancelTitle).OTHER(otherTitle).SHOW();
    alertView.DID_TOUCH = didTouchedBlock;
    
    return alertView;
}

@end
