//
//  LC_UIButton.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-16.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIButton.h"

#pragma mark -

@implementation LCUIButton
{
	BOOL _inited;
}

- (id)init
{
	self = [super init];
    
	if (self){
        
		[self initSelf];
	}
    
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self){
        
		[self initSelf];
	}
    
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
    if (self){
        
		[self initSelf];
	}
    
	return self;
}

- (void)initSelf
{
	if (NO == _inited){
        
		self.contentMode = UIViewContentModeCenter;
		self.adjustsImageWhenDisabled = YES;
		self.adjustsImageWhenHighlighted = YES;
        self.titleLabel.textAlignment = UITextAlignmentCenter;

		self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		self.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.exclusiveTouch = YES;
        
		_inited = YES;
	}
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
}

#pragma mark -

- (NSString *)title
{
	return self.currentTitle;
}

- (void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateSelected];
}

- (UIColor *)titleColor
{
	return self.currentTitleColor;
}

- (void)setTitleColor:(UIColor *)color
{
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateHighlighted];
    [self setTitleColor:color forState:UIControlStateSelected];
}

- (UIFont *)titleFont
{
	return self.titleLabel.font;
}

- (void)setTitleFont:(UIFont *)font
{
    self.titleLabel.font = font;
}

- (UIImage *)image
{
	return [self backgroundImageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image
{
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
    [self setBackgroundImage:image forState:UIControlStateSelected];
}

-(UIImage *) buttonImage
{
    return [self imageForState:UIControlStateNormal];
}

-(void) setButtonImage:(UIImage *)buttonImage
{
    [self setImage:buttonImage forState:UIControlStateNormal];
    [self setImage:buttonImage forState:UIControlStateHighlighted];
    [self setImage:buttonImage forState:UIControlStateSelected];

}

- (void)setHighlighted:(BOOL)highlighted {
    
}

@end
