//
//  LC_UITextView.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-9.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>
#import "GCPlaceholderTextView.h"

@class LCUITextView;

LC_BLOCK(BOOL, LCTextViewShouldBeginEditing, (__weak LCUITextView * textView));
LC_BLOCK(void, LCTextViewDidBeginEditing, (__weak LCUITextView * textView));
LC_BLOCK(BOOL, LCTextViewShouldEndEditing, (__weak LCUITextView * textView));
LC_BLOCK(void, LCTextViewDidEndEditing, (__weak LCUITextView * textView));
LC_BLOCK(BOOL, LCTextViewShouldChangeText, (__weak LCUITextView * textView, NSRange range, NSString * text));
LC_BLOCK(BOOL, LCTextViewShouldClear, (__weak LCUITextView * textView));
LC_BLOCK(BOOL, LCTextViewShouldReturn, (__weak LCUITextView * textView));


@interface LCUITextView : GCPlaceholderTextView

LC_PROPERTY(copy) LCTextViewShouldBeginEditing shouldBeginEditing;
LC_PROPERTY(copy) LCTextViewDidBeginEditing didBeginEditing;
LC_PROPERTY(copy) LCTextViewShouldEndEditing shouldEndEditing;
LC_PROPERTY(copy) LCTextViewDidEndEditing didEndEditing;
LC_PROPERTY(copy) LCTextViewShouldChangeText shouldChangeText;
LC_PROPERTY(copy) LCTextViewShouldClear shouldClear;
LC_PROPERTY(copy) LCTextViewShouldReturn shouldReturn;

@end
