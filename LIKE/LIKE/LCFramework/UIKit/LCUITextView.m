//
//  LC_UITextView.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-9.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUITextView.h"

@interface LCUITextView ()
@end

@implementation LCUITextView

-(void) dealloc
{
    [self unobserveAllNotifications];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {

        [self initSelf];
    }
    return self;
}

-(id) init
{
    LC_SUPER_INIT({
    
        [self initSelf];
    });
}

-(void) initSelf
{
    [self observeNotification:UITextViewTextDidBeginEditingNotification object:self];
    [self observeNotification:UITextViewTextDidChangeNotification object:self];
    [self observeNotification:UITextViewTextDidEndEditingNotification object:self];
}


#pragma mark -

LC_HANDLE_NOTIFICATION(notification)
{
    if ([notification is:UITextViewTextDidBeginEditingNotification]) {
        
        if (notification.object != self) {
            return;
        }
        
        if (self.didBeginEditing) {
            self.didBeginEditing(self);
        }
        
    }else if([notification is:UITextViewTextDidChangeNotification]){
        
        if (notification.object != self) {
            return;
        }
        
        if (self.didChanged) {
            self.didChanged(self);
        }
        
    }else if ([notification is:UITextViewTextDidEndEditingNotification]){
        
        if (notification.object != self) {
            return;
        }
        
        if (self.didEndEditing) {
            self.didEndEditing(self);
        }
    }
}


@end
