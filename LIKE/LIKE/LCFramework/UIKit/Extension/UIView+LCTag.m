//
//  UIView+Tag.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-11.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "UIView+LCTag.h"

#define KEY_TAGSTRING "UIView.TagString"

@implementation UIView (LCTag)

- (NSString *)tagString
{
    return [LCAssociate getAssociatedObject:self key:KEY_TAGSTRING];
}

- (void)setTagString:(NSString *)value
{
    [LCAssociate setAssociatedObject:self value:value key:KEY_TAGSTRING];
}

- (UIView *)viewWithTagString:(NSString *)value
{
	if ( nil == value )
		return nil;
	
	for (UIView * subview in self.subviews){
        
		NSString * tag = subview.tagString;
        
		if ([tag isEqualToString:value]){
            
			return subview;
		}
	}
	
	return nil;
}

-(LCUIViewWithTagBlock) FIND
{
    LCUIViewWithTagBlock block = ^ id (NSInteger tag)
	{
		return [self viewWithTag:tag];
	};
	
	return block;
}

-(LCUIViewWithTagStringBlock) FIND_S
{
    LCUIViewWithTagStringBlock block = ^ id (NSString * tagString)
	{
		return [self viewWithTagString:tagString];
	};
	
	return block;
}

@end
