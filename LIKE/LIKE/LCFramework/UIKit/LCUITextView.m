//
//  LC_UITextView.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-9.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUITextView.h"

@interface LCUITextViewHandle : NSObject<UITextViewDelegate>

LC_PROPERTY(assign) LCUITextView * textView;
LC_PROPERTY(assign) NSInteger maxLength;

@end

@implementation LCUITextViewHandle

- (BOOL)textViewShouldBeginEditing:(LCUITextView *)textView
{
    if (textView.shouldBeginEditing) {
        return textView.shouldBeginEditing((LCUITextView *)textView);
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(LCUITextView *)textView
{
    if (textView.didBeginEditing) {
        textView.didBeginEditing((LCUITextView *)textView);
    }
}

- (BOOL)textViewShouldEndEditing:(LCUITextView *)textView
{
    if (textView.shouldEndEditing) {
        return textView.shouldEndEditing((LCUITextView *)textView);
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(LCUITextView *)textView
{
    if (textView.didEndEditing) {
        textView.didEndEditing((LCUITextView *)textView);
    }
}

- (BOOL)textView:(LCUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.shouldChangeText) {
        return textView.shouldChangeText((LCUITextView *)textView, range, text);
    }
    
    if ([text isEqualToString:@""]) {
        return YES;
    }
    
    if (self.maxLength == 0) {
        return YES;
    }
    
    return YES;
}

- (BOOL)textViewShouldClear:(LCUITextView *)textView
{
    if (textView.shouldClear) {
        return textView.shouldClear((LCUITextView *)textView);
    }
    
    return YES;
}

- (BOOL)textViewShouldReturn:(LCUITextView *)textView
{
    if (textView.shouldReturn) {
        return textView.shouldReturn((LCUITextView *)textView);
    }
    
    return YES;
}

@end

@interface LCUITextView () <UITextViewDelegate>

LC_PROPERTY(strong) LCUITextViewHandle * handle;

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
//    [self observeNotification:UITextViewTextDidBeginEditingNotification object:self];
//    [self observeNotification:UITextViewTextDidChangeNotification object:self];
//    [self observeNotification:UITextViewTextDidEndEditingNotification object:self];
    
    self.handle = [[LCUITextViewHandle alloc] init];
    self.delegate = self.handle;
}


//#pragma mark -
//
//LC_HANDLE_NOTIFICATION(notification)
//{
//    if ([notification is:UITextViewTextDidBeginEditingNotification]) {
//        
//        if (notification.object != self) {
//            return;
//        }
//        
//        if (self.didBeginEditing) {
//            self.didBeginEditing(self);
//        }
//        
//    }else if([notification is:UITextViewTextDidChangeNotification]){
//        
//        if (notification.object != self) {
//            return;
//        }
//        
//        if (self.didChanged) {
//            self.didChanged(self);
//        }
//        
//    }else if ([notification is:UITextViewTextDidEndEditingNotification]){
//        
//        if (notification.object != self) {
//            return;
//        }
//        
//        if (self.didEndEditing) {
//            self.didEndEditing(self);
//        }
//    }
//}


@end
