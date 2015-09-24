//
//  LKTagItemView.h
//  LIKE
//
//  Created by huangweifeng on 9/24/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIView.h"
#import "LKTag.h"

@class LKTagItemView;

LC_BLOCK(void, LKTagItemViewDidRemoved, (__weak LKTagItemView * item));
LC_BLOCK(void, LKTagItemViewRequest, (__weak LKTagItemView * item));

@interface LKTagItemView : LCUIView

LC_PROPERTY(strong) LCUILabel *tagLabel;
LC_PROPERTY(strong) LCUIImageView *lineView;
LC_PROPERTY(strong) LCUILabel *likesLabel;

LC_PROPERTY(strong) LKTag *tagValue;
LC_PROPERTY(strong) LKTag *chooseTag;
LC_PROPERTY(strong) LKTag *associatedTagValue;

LC_PROPERTY(copy) LKTagItemViewRequest willRequest;
LC_PROPERTY(copy) LKTagItemViewRequest requestFinished;
LC_PROPERTY(copy) LKTagItemViewRequest customAction;

LC_PROPERTY(copy) LKTagItemViewDidRemoved didRemoved;

LC_PROPERTY(assign) BOOL showNumber;

// 设置字体大小
LC_PROPERTY(strong) UIFont *font;
// 设置背景图
LC_PROPERTY(strong) UIView *maskView;

- (void)like;

- (instancetype)initWithFont:(UIFont *)font;

@end
