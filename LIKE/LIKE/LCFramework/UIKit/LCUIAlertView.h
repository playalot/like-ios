//
//  LC_UIAlertView.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-26.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIKitBlock.h"

@class LCUIAlertView;

LC_BLOCK(void, LCUIAlertViewDidTouchedBlock, (NSInteger integerValue));
LC_BLOCK(LCUIAlertView *, LCUIAlertViewParameterString, (NSString * stringValue));
LC_BLOCK(LCUIAlertView *, LCUIAlertViewParameterNone, ());

@interface LCUIAlertView : UIAlertView

LC_PROPERTY(strong) NSObject * userInfo;
LC_PROPERTY(copy) LCUIAlertViewDidTouchedBlock DID_TOUCH;

LC_PROPERTY(readonly) LCUIAlertViewParameterString TITLE;
LC_PROPERTY(readonly) LCUIAlertViewParameterString MESSAGE;
LC_PROPERTY(readonly) LCUIAlertViewParameterString CANCEL;
LC_PROPERTY(readonly) LCUIAlertViewParameterString OTHER;

LC_PROPERTY(readonly) LCUIAlertViewParameterNone   SHOW;

+(instancetype) showWithTitle:(NSString *)title
                      message:(NSString *)message
                  cancelTitle:(NSString *)cancelTitle
                   otherTitle:(NSString *)otherTitle
              didTouchedBlock:(LCUIAlertViewDidTouchedBlock)didTouchedBlock;

@end
