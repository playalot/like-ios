//
//  LKLikeTagItemView.h
//  LIKE
//
//  Created by huangweifeng on 9/24/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIView.h"
#import "LKTag.h"

@class LKLikeTagItemView;

LC_BLOCK(void, LKLikeTagItemViewDidRemoved, (__weak LKLikeTagItemView * itemView));
LC_BLOCK(void, LKLikeTagItemViewRequest, (__weak LKLikeTagItemView * itemView));

@interface LKLikeTagItemView : LCUIView

LC_PROPERTY(strong) LCUILabel *tagLabel;
LC_PROPERTY(strong) LCUIImageView *lineView;
LC_PROPERTY(strong) LCUILabel *likesLabel;

LC_PROPERTY(strong) LKTag *tagValue;
LC_PROPERTY(strong) LKTag *chooseTag;
LC_PROPERTY(strong) LKTag *associatedTagValue;

LC_PROPERTY(copy) LKLikeTagItemViewRequest willRequest;
LC_PROPERTY(copy) LKLikeTagItemViewRequest requestFinished;
LC_PROPERTY(copy) LKLikeTagItemViewRequest customAction;

LC_PROPERTY(copy) LKLikeTagItemViewDidRemoved didRemoved;

LC_PROPERTY(assign) BOOL showNumber;

// 设置字体大小
LC_PROPERTY(strong) UIFont *font;
// 设置背景图
LC_PROPERTY(strong) UIView *maskView;

- (void)like;

- (instancetype)initWithFont:(UIFont *)font;

@end
