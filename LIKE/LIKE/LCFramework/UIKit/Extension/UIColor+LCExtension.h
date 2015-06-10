//
//  UIColor+Extension.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-21.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

LC_BLOCK(UIColor *, LCUIColorFromString, (NSString * string));

@interface UIColor (LCExtension)

+ (UIColor *) colorWithHex:(NSString *)hex;
+ (UIColor *) colorWithString:(NSString *)string;

+ (LCUIColorFromString) HEX;
+ (LCUIColorFromString) STRING; // lightgray / rgb(1,1,1) / #FFF / #FFFFFF / #FFFFFFFF

@end
