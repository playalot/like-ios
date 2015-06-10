//
//  LC_UIAnimation.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-9.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIAnimation.h"

@interface LCUIAnimation ()

@end

@implementation LCUIAnimation

@end

@implementation LCUIAnimationFade

+(LCUIAnimationFade *) animationToAlpha:(CGFloat)alpha duration:(CGFloat)duration
{
    LCUIAnimationFade * fadeTo = [[LCUIAnimationFade alloc] init];
    fadeTo.animationType = LCUIAnimationTypeFadeTo;
    fadeTo.animationDuration = duration;
    fadeTo.alpha = alpha;
    return fadeTo;
}

+(LCUIAnimationFade *) animationByAlpha:(CGFloat)alpha duration:(CGFloat)duration
{
    LCUIAnimationFade * fadeBy = [[LCUIAnimationFade alloc] init];
    fadeBy.animationType = LCUIAnimationTypeFadeBy;
    fadeBy.animationDuration = duration;
    fadeBy.alpha = alpha;
    return fadeBy;
}

@end

@implementation LCUIAnimationDisplace

+(LCUIAnimationDisplace *) animationToPoint:(CGPoint)point duration:(CGFloat)duration
{
    LCUIAnimationDisplace * animation = [[LCUIAnimationDisplace alloc] init];
    animation.point = point;
    animation.animationType = LCUIAnimationTypeDisplacementTo;
    animation.animationDuration = duration;
    return animation;
}

+(LCUIAnimationDisplace *) animationByPoint:(CGPoint)point duration:(CGFloat)duration
{
    LCUIAnimationDisplace * animation = [[LCUIAnimationDisplace alloc] init];
    animation.animationType = LCUIAnimationTypeDisplacementBy;
    animation.animationDuration = duration;
    animation.point = point;
    return animation;
}

@end

@implementation LCUIAnimationScale

+(LCUIAnimationScale *) animationToScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY duration:(CGFloat)duration
{
    LCUIAnimationScale * animation = [[LCUIAnimationScale alloc] init];
    animation.animationType = LCUIAnimationTypeScaleTo;
    animation.animationDuration = duration;
    animation.scaleX = scaleX;
    animation.scaleY = scaleY;
    return animation;
}

+(LCUIAnimationScale *) animationByScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY duration:(CGFloat)duration;
{
    LCUIAnimationScale * animation = [[LCUIAnimationScale alloc] init];
    animation.animationType = LCUIAnimationTypeScaleBy;
    animation.animationDuration = duration;
    animation.scaleX = scaleX;
    animation.scaleY = scaleY;
    return animation;
}

@end

@implementation LCUIAnimationRotate

+(LCUIAnimationRotate *) animationToRotate:(CGFloat)angle duration:(CGFloat)duration
{
    LCUIAnimationRotate * animation = [[LCUIAnimationRotate alloc] init];
    animation.animationType = LCUIAnimationTypeRotateTo;
    animation.animationDuration = duration;
    animation.angle = angle;
    return animation;
}

+(LCUIAnimationRotate *) animationByRotate:(CGFloat)angle duration:(CGFloat)duration;
{
    LCUIAnimationRotate * animation = [[LCUIAnimationRotate alloc] init];
    animation.animationType = LCUIAnimationTypeRotateBy;
    animation.animationDuration = duration;
    animation.angle = angle;
    return animation;
}

@end


@interface LCUIAnimationQueue()

LC_PROPERTY(strong) NSMutableArray * actionList;

@end


@implementation LCUIAnimationQueue

-(id)init
{
    LC_SUPER_INIT({
    
        self.actionList = [NSMutableArray array];
    
    });
}

-(LCUIAnimation *) getFirstAnimation
{
    return self.actionList.firstObject;
}

-(void) removeFirstAnimation
{
    if([self.actionList count])
        [self.actionList removeObjectAtIndex:0];
}

-(void) addAnimation:(LCUIAnimation *)animation
{
    if (animation)
        [self.actionList addObject:animation];
}

-(void) runAnimationsInView:(UIView *)view
{    
    if (!self.actionList) {
        return;
    }
    
    CGPoint center = view.center;
    CGFloat alpha = view.alpha;
    CGAffineTransform transform = view.transform;
    
    LCUIAnimation * animation = [self getFirstAnimation];
    
    switch (animation.animationType){
            
        case LCUIAnimationTypeDisplacementTo:{
            
            LCUIAnimationDisplace * displaceMent = (LCUIAnimationDisplace *)animation;
            center.x = displaceMent.point.x;
            center.y = displaceMent.point.y;
            break;
        }
        case LCUIAnimationTypeDisplacementBy:{
            
            LCUIAnimationDisplace * displaceMent = (LCUIAnimationDisplace *)animation;
            center.x+=displaceMent.point.x;
            center.y+=displaceMent.point.y;
            break;
        }
        case LCUIAnimationTypeFadeTo:{
            
            LCUIAnimationFade * fadeAnimation = (LCUIAnimationFade *)animation;
            alpha=fadeAnimation.alpha;
            break;
        }
        case LCUIAnimationTypeFadeBy:
        {
            LCUIAnimationFade * fadeAnimation = (LCUIAnimationFade *)animation;
            alpha+=fadeAnimation.alpha;
            break;
        }
        case LCUIAnimationTypeScaleBy:
        {
            LCUIAnimationScale * scale = (LCUIAnimationScale *)animation;
            transform.a = scale.scaleX;
            transform.d = scale.scaleY;
            break;
        }
        case LCUIAnimationTypeScaleTo:
        {
            LCUIAnimationScale * scale = (LCUIAnimationScale *)animation;
            transform = CGAffineTransformMakeScale(scale.scaleX,
                                                   scale.scaleY);
            break;
        }
        case LCUIAnimationTypeRotateBy:
        {
            LCUIAnimationRotate * rotate = (LCUIAnimationRotate *)animation;
            CGFloat radians = rotate.angle * M_PI/180;
            CGAffineTransform rotatedTransform = CGAffineTransformRotate(transform,radians);
            transform  = rotatedTransform;
            break;
        }
        case LCUIAnimationTypeRotateTo:
        {
            LCUIAnimationRotate * rotate =(LCUIAnimationRotate *)animation;
            CGFloat radians = rotate.angle * M_PI/180;
            transform = CGAffineTransformMakeRotation(radians);
            break;
        }
            
        default:
            break;
    }
    
    LC_FAST_ANIMATIONS_O_F(animation.animationDuration, UIViewAnimationOptionCurveLinear, ^{
    
        view.center    = center;
        view.alpha     = alpha;
        view.transform = transform;
    
    },^(BOOL finished){
        
       [self removeFirstAnimation];
       
       if (self.actionList.count == 0){
           
           if (self.CALLBACK) {
               self.CALLBACK(finished);
           }
           return;
       }
       
       [self runAnimationsInView:view];
    });

}


@end