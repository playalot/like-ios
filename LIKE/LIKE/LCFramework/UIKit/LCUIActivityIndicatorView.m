//
//  LCUIActivityIndicatorView.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCUIActivityIndicatorView.h"

@implementation LCUIActivityIndicatorView

+(LCUIActivityIndicatorView *) whiteView
{
    return [[LCUIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
}

+(LCUIActivityIndicatorView *) grayView
{
    return [[LCUIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
    self = [super initWithActivityIndicatorStyle:style];
    
    if (self){
        
        [self initSelf];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self){
        
        [self initSelf];
    }
    
    return self;
}

- (void)initSelf
{
    self.hidden = YES;
    self.hidesWhenStopped = YES;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    self.color = [UIColor whiteColor];
}

- (BOOL)animating
{
    return self.isAnimating;
}

- (void)setAnimating:(BOOL)flag
{
    if (flag){
        
        [self startAnimating];
    }
    else{
        [self stopAnimating];
    }
}

- (void)startAnimating
{
    if (self.isAnimating)
        return;
    
    self.hidden = NO;
    self.alpha = 1.0f;
    
    [super startAnimating];
}

- (void)stopAnimating
{
    if (NO == self.isAnimating)
        return;
    
    self.hidden = YES;
    self.alpha = 0.0f;
    
    [super stopAnimating];    
}

@end
