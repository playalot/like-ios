//
//  UIView+Tag.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-11.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>

LC_BLOCK(id, LCUIViewWithTagBlock, (NSInteger tag));
LC_BLOCK(id, LCUIViewWithTagStringBlock, (NSString * tagString));

@interface UIView (LCTag)

LC_PROPERTY(readonly) LCUIViewWithTagBlock         FIND;
LC_PROPERTY(readonly) LCUIViewWithTagStringBlock   FIND_S;

LC_PROPERTY(copy) NSString * tagString;

- (UIView *)viewWithTagString:(NSString *)value;

@end
