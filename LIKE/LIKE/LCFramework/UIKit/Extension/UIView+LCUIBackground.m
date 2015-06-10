//
//  UIView+Background.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-11.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "UIView+LCUIBackground.h"

#pragma mark -

@interface __LCUIBackgroundView : LCUIImageView
@end

#pragma mark -

@implementation __LCUIBackgroundView
@end

@implementation UIView (LCUIBackground)

- (LCUIImageView *) backgroundImageView
{
	LCUIImageView * imageView = nil;
	
	for (UIView * subView in self.subviews){
        
		if ([subView isKindOfClass:[__LCUIBackgroundView class]]){
            
			imageView = (LCUIImageView *)subView;
            imageView.frame = self.bounds;
			break;
		}
	}
    
	if (nil == imageView){
        
		imageView = [[__LCUIBackgroundView alloc] initWithFrame:self.bounds];
		imageView.autoresizesSubviews = YES;
 		imageView.autoresizingMask = UIViewAutoresizingNone;
		imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        
		[self addSubview:imageView];
		[self sendSubviewToBack:imageView];
	}
	
	return imageView;
}

@end
