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
/**
 *  主页相机按钮
 */
LC_PROPERTY(strong) UIView * view;

/**
 *  选中状态
 */
LC_PROPERTY(copy) LKAssistiveTouchButtonTouchEnd didSelected;

/**
 *  按下状态
 */
LC_PROPERTY(copy) LKAssistiveTouchButtonTouchDown touchDown;

/**
 *  点击结束状态
 */
LC_PROPERTY(copy) LKAssistiveTouchButtonTouchEnd touchEnd;

-(id)initWithFrame:(CGRect)frame inView:(UIView *)inView;

@end
