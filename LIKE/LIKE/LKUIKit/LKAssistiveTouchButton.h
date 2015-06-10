//
//  LKAssistiveTouchButton.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUILabel.h"

LC_BLOCK(void, LKAssistiveTouchButtonTouchDown, ());
LC_BLOCK(void, LKAssistiveTouchButtonTouchEnd, ());

@interface LKAssistiveTouchButton : LCUILabel

LC_PROPERTY(strong) UIView * view;

LC_PROPERTY(copy) LKAssistiveTouchButtonTouchEnd didSelected;
LC_PROPERTY(copy) LKAssistiveTouchButtonTouchDown touchDown;
LC_PROPERTY(copy) LKAssistiveTouchButtonTouchEnd touchEnd;

-(id)initWithFrame:(CGRect)frame inView:(UIView *)inView;

@end
