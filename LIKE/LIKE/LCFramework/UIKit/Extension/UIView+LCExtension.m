//
//  UIView+LCExtension.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "UIView+LCExtension.h"

@implementation UIView (LCExtension)

- (LCUIViewAddSubview)ADD {
    LCUIViewAddSubview block = ^ id (UIView * obj) {
        [self addSubview:obj];
        return self;
    };
    
    return block;
}

- (LCUIViewSizeToFit)FIT {
    LCUIViewSizeToFit block = ^ id (){
        [self sizeToFit];
        return self;
    };
    
    return block;
}

- (LCUIViewColor) COLOR {
    LCUIViewSizeToFit block = ^ id (UIColor * color){
        self.backgroundColor = color;
        return self;
    };
    
    return block;
}

+ (LCUIViewCreate) CREATE {
    LCUIViewCreate block = ^ id (CGFloat x, CGFloat y, CGFloat width, CGFloat height){
        return [[self class] viewWithFrame:LC_RECT(x, y, width, height)];
    };
    return block;
}

+ (instancetype)VIEW
{
    return [[self alloc] init];
}

+ (instancetype)view
{
    return [[self alloc] init];
}

+ (instancetype)viewWithFrame:(CGRect)frame
{
    return [[self alloc] initWithFrame:frame];
}

- (void)removeAllSubviews
{
    NSArray * array = [self.subviews copy];
    
    for (UIView * view in array){
        
        [view removeFromSuperview];
    }
}


- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    if ([self isKindOfClass:[UIImageView class]]) {
        self.layer.masksToBounds = YES;
    } else {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale; // or [UIScreen mainScreen]
    }
    
}

-(CGFloat) cornerRadius
{
    return self.layer.cornerRadius;
}

-(void) setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

-(CGFloat) borderWidth
{
    return self.layer.borderWidth;
}

-(void) setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

-(UIColor *)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

-(BOOL) roundMask
{
    return self.layer.mask ? YES : NO;
}

- (void) setRoundMask:(BOOL)roundMask
{
    if (roundMask) {
        
        CAShapeLayer * circle = [CAShapeLayer layer];
        circle.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.viewMidHeight].CGPath;
        circle.fillColor = [UIColor blackColor].CGColor;
        self.layer.mask = circle;
    }
    else{
        
        self.layer.mask = nil;
    }
}

- (void) drawImage:(UIImage *)image inRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    
}

@end
