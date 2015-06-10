//
//  LC_UIActionSheet.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

@class LCUIActionSheet;

LC_BLOCK(void, LCUIActionSheetDidSelected, (NSInteger integerValue));
LC_BLOCK(LCUIActionSheet *, LCUIActionSheetParameterString, (NSString * stringValue));
LC_BLOCK(LCUIActionSheet *, LCUIActionSheetParameterNone, ());
LC_BLOCK(LCUIActionSheet *, LCUIActionSheetShow, (UIView * inView));

@interface LCUIActionSheet : UIActionSheet

LC_PROPERTY(copy) LCUIActionSheetDidSelected DID_SELECTED;

LC_PROPERTY(readonly) LCUIActionSheetParameterString TITLE;
LC_PROPERTY(readonly) LCUIActionSheetParameterString ADD;
LC_PROPERTY(readonly) LCUIActionSheetShow SHOW;

-(void) showInView:(UIView *)view animated:(BOOL)animated;

@end
