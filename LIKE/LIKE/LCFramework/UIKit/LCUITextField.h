//
//  LC_UITextField.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-16.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

@class LCUITextField;

LC_BLOCK(BOOL, LCTextFieldShouldBeginEditing, (__weak LCUITextField * textField));
LC_BLOCK(void, LCTextFieldDidBeginEditing, (__weak LCUITextField * textField));
LC_BLOCK(BOOL, LCTextFieldShouldEndEditing, (__weak LCUITextField * textField));
LC_BLOCK(void, LCTextFieldDidEndEditing, (__weak LCUITextField * textField));
LC_BLOCK(BOOL, LCTextFieldShouldChangeCharacters, (__weak LCUITextField * textField, NSRange range, NSString * string));
LC_BLOCK(BOOL, LCTextFieldShouldClear, (__weak LCUITextField * textField));
LC_BLOCK(BOOL, LCTextFieldShouldReturn, (__weak LCUITextField * textField));


@interface LCUITextField : UITextField

LC_PROPERTY(copy) LCTextFieldShouldBeginEditing shouldBeginEditing;
LC_PROPERTY(copy) LCTextFieldDidBeginEditing didBeginEditing;
LC_PROPERTY(copy) LCTextFieldShouldEndEditing shouldEndEditing;
LC_PROPERTY(copy) LCTextFieldDidEndEditing didEndEditing;
LC_PROPERTY(copy) LCTextFieldShouldChangeCharacters shouldChangeCharacters;
LC_PROPERTY(copy) LCTextFieldShouldClear shouldClear;
LC_PROPERTY(copy) LCTextFieldShouldReturn shouldReturn;

LC_PROPERTY(strong) UIColor * placeholderColor;
LC_PROPERTY(assign) NSInteger maxLength;

LC_PROPERTY(assign) CGFloat leftContentPadding;
LC_PROPERTY(assign) CGFloat rightContentPadding;

@end
