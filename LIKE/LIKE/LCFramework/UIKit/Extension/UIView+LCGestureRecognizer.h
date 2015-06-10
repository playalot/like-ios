//
//  NSObject+LCGestureRecognizer.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (LCGestureRecognizer)

LC_PROPERTY(readonly) UITapGestureRecognizer * tapGestureRecognizer;
LC_PROPERTY(readonly) UIPanGestureRecognizer * panGestureRecognizer;
LC_PROPERTY(readonly) UIPinchGestureRecognizer * pinchGestureRecognizer;

LC_PROPERTY(readonly) CGPoint panOffset;
LC_PROPERTY(readonly) CGFloat pinchScale;


-(UITapGestureRecognizer *) addTapGestureRecognizer:(id)target selector:(SEL)selector;
-(UIPanGestureRecognizer *) addPanGestureRecognizer:(id)target selector:(SEL)selector;
-(UIPinchGestureRecognizer *) addPinchGestureRecognizer:(id)target selector:(SEL)selector;

@end
