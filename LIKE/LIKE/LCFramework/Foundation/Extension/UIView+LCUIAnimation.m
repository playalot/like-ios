//
//  UIView+LCUIAnimation.m
//  LCFrameworkDemo
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "UIView+LCUIAnimation.h"
#import "LCUIAnimation.h"

@implementation UIView (LCUIAnimation)

-(LCUIAnimationQueueRun) RUN_ANIMATIONS
{
    LCUIAnimationQueueRun block = ^ void (LCUIAnimationQueue * queue){
        
        [self runAnimationsQueue:queue];
    };
    
    return block;
}

-(void) runAnimationsQueue:(LCUIAnimationQueue *)queue
{
    [queue runAnimationsInView:self];
}


@end
