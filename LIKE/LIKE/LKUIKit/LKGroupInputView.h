//
//  LKGroupInputView.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCPlaceholderTextView.h"

LC_BLOCK(void, LKInputViewSend, (NSString * text));
LC_BLOCK(void, LKInputViewWillDismiss, (NSString * text));

LC_BLOCK(void, LKInputViewDidShow, ());

@interface LKGroupInputView : UIView

LC_PROPERTY(copy) LKInputViewWillDismiss willDismiss;
LC_PROPERTY(copy) LKInputViewSend sendAction;
LC_PROPERTY(copy) LKInputViewDidShow didShow;

LC_PROPERTY(strong) id userInfo;
LC_PROPERTY(strong) LCUIButton * imageButton;
LC_PROPERTY(strong) LCUITextField * textField;
LC_PROPERTY(strong) LCUIButton * dismissButton;

@end
