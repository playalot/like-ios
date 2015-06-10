//
//  NSObject+Hud.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-30.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <Foundation/Foundation.h>

LC_BLOCK(LCUIHud *, LCUIHudShow, (NSString * message));

@interface NSObject (LCUIHud)

LC_PROPERTY(readonly) LCUIHudShow SHOW_MESSAGE;
LC_PROPERTY(readonly) LCUIHudShow SHOW_SUCCESS;
LC_PROPERTY(readonly) LCUIHudShow SHOW_FAILED;
LC_PROPERTY(readonly) LCUIHudShow SHOW_LOADING;
LC_PROPERTY(readonly) LCUIHudShow SHOW_PREOGRESS;


- (LCUIHud *)showMessageHud:(NSString *)message;
- (LCUIHud *)showSuccessHud:(NSString *)message;
- (LCUIHud *)showFailureHud:(NSString *)message;
- (LCUIHud *)showLoadingHud:(NSString *)message;
- (LCUIHud *)showProgressHud:(NSString *)message;

@end
