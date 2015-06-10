//
//  NSObject+LCGestureRecognizer.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "UIView+LCGestureRecognizer.h"


#pragma mark -

@interface __LCTapGestureRecognizer : UITapGestureRecognizer

@end

@implementation __LCTapGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    
    if ( self )
    {
        self.numberOfTapsRequired = 1;
        self.numberOfTouchesRequired = 1;
        self.cancelsTouchesInView = YES;
        self.delaysTouchesBegan = YES;
        self.delaysTouchesEnded = YES;
    }
    
    return self;
}

@end

#pragma mark -

@interface __LCPanGestureRecognizer : UIPanGestureRecognizer

@end

@implementation __LCPanGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    
    if ( self )
    {
        
    }
    
    return self;
}

@end

#pragma mark -

@interface __LCPinchGestureRecognizer : UIPinchGestureRecognizer
@end

@implementation __LCPinchGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    
    if ( self )
    {
        
    }
    
    return self;
}

@end


@implementation UIView (LCGestureRecognizer)

- (CGPoint) panOffset
{
    return [self.panGestureRecognizer translationInView:self];
}

- (CGFloat) pinchScale
{
    UIPinchGestureRecognizer * gesture = self.pinchGestureRecognizer;
    
    if (nil == gesture){
        
        return 1.0f;
    }
    
    return gesture.scale;
}

- (UITapGestureRecognizer *) tapGestureRecognizer
{
    __LCTapGestureRecognizer * tapGestureRecognizer = nil;
    
    for (UIGestureRecognizer * gesture in self.gestureRecognizers){
        
        if ([gesture isKindOfClass:[__LCTapGestureRecognizer class]]){
            
            tapGestureRecognizer = (__LCTapGestureRecognizer *)gesture;
        }
    }
    
    return tapGestureRecognizer;
}

- (UIPanGestureRecognizer *) panGestureRecognizer
{
    __LCPanGestureRecognizer * panGestureRecognizer = nil;
    
    for (UIGestureRecognizer * gesture in self.gestureRecognizers){
        
        if ([gesture isKindOfClass:[__LCPanGestureRecognizer class]]){
            
            panGestureRecognizer = (__LCPanGestureRecognizer *)gesture;
        }
    }
    
    return panGestureRecognizer;
}

- (UIPinchGestureRecognizer *) pinchGestureRecognizer
{
    __LCPinchGestureRecognizer * pinchGestureRecognizer = nil;
    
    for (UIGestureRecognizer * gesture in self.gestureRecognizers){
        
        if ([gesture isKindOfClass:[__LCPinchGestureRecognizer class]]){
            
            pinchGestureRecognizer = (__LCPinchGestureRecognizer *)gesture;
        }
    }
    
    return pinchGestureRecognizer;
}

-(UITapGestureRecognizer *) addTapGestureRecognizer:(id)target selector:(SEL)selector
{
    __LCTapGestureRecognizer * tapGesture = [[__LCTapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tapGesture];
    
    return tapGesture;
}

-(UIPanGestureRecognizer *) addPanGestureRecognizer:(id)target selector:(SEL)selector
{
    __LCPanGestureRecognizer * panGesture = [[__LCPanGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:panGesture];
    
    return panGesture;
}

-(UIPinchGestureRecognizer *) addPinchGestureRecognizer:(id)target selector:(SEL)selector
{
    __LCPinchGestureRecognizer * pinchGesture = [[__LCPinchGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:pinchGesture];
    
    return pinchGesture;
}








@end
