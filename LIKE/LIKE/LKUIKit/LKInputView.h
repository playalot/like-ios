//
//  IFInputView.h
//  IFAPP
//
//  Created by Leer on 15/3/17.
//  Copyright (c) 2015年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(void, LKInputViewSend, (NSString * text));
LC_BLOCK(void, LKInputViewWillDismiss, (NSString * text));

LC_BLOCK(void, LKInputViewDidShow, ());

@interface LKInputView : LCUIBlurView

LC_PROPERTY(copy) LKInputViewWillDismiss willDismiss;
LC_PROPERTY(copy) LKInputViewSend sendAction;
LC_PROPERTY(copy) LKInputViewDidShow didShow;

LC_PROPERTY(strong) id userInfo;
LC_PROPERTY(strong) LCUITextField * textField;
LC_PROPERTY(strong) LCUIButton * dismissButton;

@end
