//
//  UIViewController+Title.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "UIViewController+LCTitle.h"

@implementation UIViewController (LCTitle)

- (UIImage *)titleImage
{
	UIImageView * imageView = (UIImageView *)self.navigationItem.titleView;
    
	if (imageView && [imageView isKindOfClass:[UIImageView class]]){
        
		return imageView.image;
	}
	
	return nil;
}

- (void)setTitleImage:(UIImage *)image
{
	UIImageView * imageView = [LCUIImageView viewWithImage:image];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.navigationItem.titleView = imageView;
}

- (UIView *)titleView
{
	return self.navigationItem.titleView;
}

- (void)setTitleView:(UIView *)view
{
	self.navigationItem.titleView = view;
}

@end
