//
//  LKNotificationHeader.h
//  LIKE
//
//  Created by huangweifeng on 9/14/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIView.h"

@interface LKNotificationHeader : LCUIView

LC_PROPERTY(strong) LCUIImageView * headImageView;
LC_PROPERTY(strong) LCUILabel * nameLabel;
LC_PROPERTY(strong) UIView * blurView;
LC_PROPERTY(strong) LCUIImageView * backgroundView;

- (instancetype)initWithCGSize:(CGSize)size;

@end
