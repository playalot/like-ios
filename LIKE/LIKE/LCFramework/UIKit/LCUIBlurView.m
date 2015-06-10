//
//  LC_UIBlurView.m
//  LCFramework
//
//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 14-2-19.
//  Copyright (c) 2014年 Licheng Guo iOS Developer ( http://nsobject.me ). All rights reserved.
//

#import "LCUIBlurView.h"

@interface LCUIBlurView ()

LC_PROPERTY(strong) UIToolbar * toolbar;

@end

@implementation LCUIBlurView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initSelf];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initSelf];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self initSelf];
    }
    
    return self;
}

- (void)initSelf
{
    // If we don't clip to bounds the toolbar draws a thin shadow on top
    [self setClipsToBounds:YES];
    
    if (!self.toolbar)
    {
        self.toolbar =  [[UIToolbar alloc] initWithFrame:[self bounds]];
        [self.layer addSublayer:[self.toolbar layer]];
    }
}

- (void) setTintColor:(UIColor *)tintColor
{
    [self.toolbar setBarTintColor:tintColor];
}

-(void) setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    
    self.toolbar.layer.cornerRadius = cornerRadius;
    self.toolbar.layer.masksToBounds = YES;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.toolbar.frame = self.bounds;
}

@end
