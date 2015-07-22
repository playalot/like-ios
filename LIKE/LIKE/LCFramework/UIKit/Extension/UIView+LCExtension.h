//
//  UIView+LCExtension.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <UIKit/UIKit.h>

CG_EXTERN const CGRect LCRectZero;

LC_BLOCK(id, LCUIViewAddSubview, (id obj));
LC_BLOCK(id, LCUIViewSizeToFit, ());
LC_BLOCK(id, LCUIViewCreate, (CGFloat x, CGFloat y, CGFloat width, CGFloat height));
LC_BLOCK(id, LCUIViewColor, (UIColor * color));

@interface UIView (LCExtension)

LC_PROPERTY(readonly) LCUIViewAddSubview ADD;
LC_PROPERTY(readonly) LCUIViewSizeToFit  FIT;
LC_PROPERTY(readonly) LCUIViewColor COLOR;

LC_PROPERTY(assign) CGFloat cornerRadius;
LC_PROPERTY(assign) CGFloat borderWidth;
LC_PROPERTY(strong) UIColor * borderColor;
LC_PROPERTY(assign) BOOL roundMask;

+ (LCUIViewCreate) CREATE;

+ (instancetype)VIEW;
+ (instancetype)view;
+ (instancetype)viewWithFrame:(CGRect)frame;

- (void) removeAllSubviews;

@end
