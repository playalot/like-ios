//
//  UIView+LCFrameLayout.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <UIKit/UIKit.h>

LC_BLOCK(UIView *, LCFrameLayoutParameterFloat, (CGFloat value));

@interface UIView (LCFrameLayout)

LC_PROPERTY(assign) CGPoint viewXY;
LC_PROPERTY(assign) CGSize viewSize;

LC_PROPERTY(assign) CGFloat viewCenterX;
LC_PROPERTY(assign) CGFloat viewCenterY;

LC_PROPERTY(assign) CGFloat viewFrameX;
LC_PROPERTY(assign) CGFloat viewFrameY;
LC_PROPERTY(assign) CGFloat viewFrameWidth;
LC_PROPERTY(assign) CGFloat viewFrameHeight;

LC_PROPERTY(readonly) CGFloat viewRightX;
LC_PROPERTY(readonly) CGFloat viewBottomY;

LC_PROPERTY(readonly) CGFloat viewMidX;
LC_PROPERTY(readonly) CGFloat viewMidY;

LC_PROPERTY(readonly) CGFloat viewMidWidth;
LC_PROPERTY(readonly) CGFloat viewMidHeight;

LC_PROPERTY(readonly) LCFrameLayoutParameterFloat X;
LC_PROPERTY(readonly) LCFrameLayoutParameterFloat Y;
LC_PROPERTY(readonly) LCFrameLayoutParameterFloat WIDTH;
LC_PROPERTY(readonly) LCFrameLayoutParameterFloat HEIGHT;

LC_PROPERTY(readonly) LCFrameLayoutParameterFloat LEFT;
LC_PROPERTY(readonly) LCFrameLayoutParameterFloat TOP;
LC_PROPERTY(readonly) LCFrameLayoutParameterFloat RIGHT;
LC_PROPERTY(readonly) LCFrameLayoutParameterFloat BOTTOM;

@end
