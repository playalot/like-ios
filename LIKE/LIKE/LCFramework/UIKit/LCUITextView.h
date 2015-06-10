//
//  LC_UITextView.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-9.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

@class LCUITextView;

LC_BLOCK(void, LCUITextViewDidBeginEditing, (__weak LCUITextView * textView));
LC_BLOCK(void, LCUITextViewDidChanged, (__weak LCUITextView * textView));
LC_BLOCK(void, LCUITextViewDidEndEditing, (__weak LCUITextView * textView));


@interface LCUITextView : UITextView

LC_PROPERTY(copy) LCUITextViewDidBeginEditing didBeginEditing;
LC_PROPERTY(copy) LCUITextViewDidChanged didChanged;
LC_PROPERTY(copy) LCUITextViewDidEndEditing didEndEditing;

@end
