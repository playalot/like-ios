//
//  LC_UIAnimation.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-9.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <Foundation/Foundation.h>

#import "UIView+LCUIAnimation.h"


typedef NS_ENUM (NSInteger, LCUIAnimationType)
{
    LCUIAnimationTypeNone = 0,
    LCUIAnimationTypeDisplacementBy,
    LCUIAnimationTypeDisplacementTo,
    LCUIAnimationTypeFadeBy,
    LCUIAnimationTypeFadeTo,
    LCUIAnimationTypeScaleBy,
    LCUIAnimationTypeScaleTo,
    LCUIAnimationTypeRotateBy,
    LCUIAnimationTypeRotateTo,
    LCUIAnimationTypeCallBack,
};


#pragma mark -


@interface LCUIAnimation : NSObject

LC_PROPERTY(assign) LCUIAnimationType animationType;
LC_PROPERTY(assign) CGFloat animationDuration;

@end


#pragma mark -


@interface LCUIAnimationFade : LCUIAnimation

LC_PROPERTY(assign) CGFloat alpha;

+(LCUIAnimationFade *)animationToAlpha:(CGFloat)alpha duration:(CGFloat)duration;
+(LCUIAnimationFade *)animationByAlpha:(CGFloat)alpha duration:(CGFloat)duration;

@end


#pragma mark -


@interface LCUIAnimationDisplace : LCUIAnimation

LC_PROPERTY(assign) CGPoint point;

+(LCUIAnimationDisplace *)animationToPoint:(CGPoint)point duration:(CGFloat)duration;
+(LCUIAnimationDisplace *)animationByPoint:(CGPoint)point duration:(CGFloat)duration;

@end


#pragma mark -


@interface LCUIAnimationScale : LCUIAnimation

LC_PROPERTY(assign) CGFloat scaleX;
LC_PROPERTY(assign) CGFloat scaleY;

+(LCUIAnimationScale *)animationToScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY duration:(CGFloat)duration;
+(LCUIAnimationScale *)animationByScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY duration:(CGFloat)duration;

@end


#pragma mark -


@interface LCUIAnimationRotate : LCUIAnimation

/** 角度值 */
LC_PROPERTY(assign) CGFloat angle;

+(LCUIAnimationRotate *)animationToRotate:(CGFloat)angle duration:(CGFloat)duration;
+(LCUIAnimationRotate *)animationByRotate:(CGFloat)angle duration:(CGFloat)duration;

@end


#pragma mark -

LC_BLOCK(void, LCUIAnimationCallBack, (BOOL finished));
LC_BLOCK(void, LCUIAnimationAdd, (LCUIAnimation * animation));

@interface LCUIAnimationQueue :NSObject

LC_PROPERTY(readonly) LCUIAnimationAdd ADD;
LC_PROPERTY(copy) LCUIAnimationCallBack CALLBACK;

-(void) addAnimation:(LCUIAnimation *)animation;
-(void) runAnimationsInView:(UIView *)view;

@end


#pragma mark -


