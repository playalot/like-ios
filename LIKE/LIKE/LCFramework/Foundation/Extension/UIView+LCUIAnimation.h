//
//  UIView+LCUIAnimation.h
//  LCFrameworkDemo
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCUIAnimation.h"

@class LCUIAnimationQueue;

LC_BLOCK(void, LCUIAnimationQueueRun, (LCUIAnimationQueue * queue));

@interface UIView (LCUIAnimation)

LC_PROPERTY(readonly) LCUIAnimationQueueRun RUN_ANIMATIONS;

-(void) runAnimationsQueue:(LCUIAnimationQueue *)queue;

@end
