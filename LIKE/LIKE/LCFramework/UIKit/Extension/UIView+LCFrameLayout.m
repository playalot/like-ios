//
//  UIView+LCFrameLayout.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "UIView+LCFrameLayout.h"

@implementation UIView (LCFrameLayout)

-(CGPoint) viewXY
{
    return CGPointMake(self.viewFrameX, self.viewFrameY);
}

-(void) setViewXY:(CGPoint)viewXY
{
    self.viewFrameX = viewXY.x;
    self.viewFrameY = viewXY.y;
}

-(CGSize) viewSize
{
    return LC_SIZE(self.viewFrameWidth, self.viewFrameHeight);
}

-(void) setViewSize:(CGSize)viewSize
{
    self.viewFrameWidth = viewSize.width;
    self.viewFrameHeight = viewSize.height;
}

-(CGFloat) viewCenterX
{
    return self.center.x;
}

-(void) setViewCenterX:(CGFloat)viewCenterX
{
    self.center = LC_POINT(viewCenterX, self.viewCenterY);
}

-(CGFloat) viewCenterY
{
    return self.center.y;
}

-(void) setViewCenterY:(CGFloat)viewCenterY
{
    self.center = LC_POINT(self.viewCenterX, viewCenterY);
}


-(CGFloat) viewFrameX
{
    return self.frame.origin.x;
}

-(void) setViewFrameX:(CGFloat)newViewFrameX
{
    self.frame = LC_RECT_CREATE(newViewFrameX, self.viewFrameY, self.viewFrameWidth, self.viewFrameHeight);
}

-(CGFloat) viewFrameY
{
    return self.frame.origin.y;
}

-(void) setViewFrameY:(CGFloat)newViewFrameY
{
    self.frame = LC_RECT_CREATE(self.viewFrameX, newViewFrameY, self.viewFrameWidth, self.viewFrameHeight);
}

-(CGFloat) viewFrameWidth
{
    return self.frame.size.width;
}

-(void) setViewFrameWidth:(CGFloat)newViewFrameWidth
{
    self.frame = LC_RECT_CREATE(self.viewFrameX, self.viewFrameY, newViewFrameWidth, self.viewFrameHeight);
}

-(CGFloat) viewFrameHeight
{
    return self.frame.size.height;
}

-(void) setViewFrameHeight:(CGFloat)newViewFrameHeight
{
    self.frame = LC_RECT_CREATE(self.viewFrameX, self.viewFrameY, self.viewFrameWidth, newViewFrameHeight);
}

-(CGFloat) viewRightX
{
    return self.viewFrameX+self.viewFrameWidth;
}

-(CGFloat) viewBottomY
{
    return self.viewFrameY+self.viewFrameHeight;
}

-(CGFloat) viewMidX
{
    return self.viewFrameX / 2.f;
}

-(CGFloat) viewMidY
{
    return self.viewFrameY / 2.f;
}

-(CGFloat) viewMidWidth
{
    return self.viewFrameWidth / 2.f;
}

-(CGFloat) viewMidHeight
{
    return self.viewFrameHeight / 2.f;
}


#pragma mark - 



-(LCFrameLayoutParameterFloat) X
{
    LCFrameLayoutParameterFloat block = ^ UIView * (CGFloat value){
        
        self.viewFrameX = value;
        return self;
    };
    
    return block;
}

-(LCFrameLayoutParameterFloat) Y
{
    LCFrameLayoutParameterFloat block = ^ UIView * (CGFloat value){
        
        self.viewFrameY = value;
        return self;
    };
    
    return block;
}

-(LCFrameLayoutParameterFloat) WIDTH
{
    LCFrameLayoutParameterFloat block = ^ UIView * (CGFloat value){
        
        self.viewFrameWidth = value;
        return self;
    };
    
    return block;
}

-(LCFrameLayoutParameterFloat) HEIGHT
{
    LCFrameLayoutParameterFloat block = ^ UIView * (CGFloat value){
        
        self.viewFrameHeight = value;
        return self;
    };
    
    return block;
}

-(LCFrameLayoutParameterFloat) LEFT
{
    LCFrameLayoutParameterFloat block = ^ UIView * (CGFloat value){
        
        self.viewFrameX = value;
        return self;
    };
    
    return block;
}

-(LCFrameLayoutParameterFloat) TOP
{
    LCFrameLayoutParameterFloat block = ^ UIView * (CGFloat value){
        
        self.viewFrameY = value;
        return self;
    };
    
    return block;
}

-(LCFrameLayoutParameterFloat) RIGHT
{
    LCFrameLayoutParameterFloat block = ^ UIView * (CGFloat value){
        
        self.viewFrameWidth = self.superview.viewFrameWidth - self.viewFrameX - value;
        return self;
    };
    
    return block;
}

-(LCFrameLayoutParameterFloat) BOTTOM
{
    LCFrameLayoutParameterFloat block = ^ UIView * (CGFloat value){
        
        self.viewFrameHeight = self.superview.viewFrameHeight - self.viewFrameY - value;
        return self;
    };
    
    return block;
}

@end
