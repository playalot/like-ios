//
//  LKHomepageHeader.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "BLKFlexibleHeightBar.h"

LC_BLOCK(void, LKHomepageHeaderTap, (UIImageView * imageView));

@interface LKHomepageHeader : BLKFlexibleHeightBar

LC_PROPERTY(assign) CGFloat preMaxHeight;
LC_PROPERTY(assign) CGFloat preMinHeight;

LC_PROPERTY(strong) LCUILabel * nameLabel;
LC_PROPERTY(strong) LCUILabel * nameLabelOnShowing;
LC_PROPERTY(strong) LCUIImageView * headImageView;
LC_PROPERTY(strong) LCUIImageView * backgroundView;
LC_PROPERTY(strong) UIImageView * icon;
LC_PROPERTY(strong) UIView * maskView;

LC_PROPERTY(copy) LKHomepageHeaderTap headAction;
LC_PROPERTY(copy) LKHomepageHeaderTap backgroundAction;
LC_PROPERTY(copy) LKHomepageHeaderTap labelAction;

LC_PROPERTY(assign) UIScrollView * scrollView;

-(void) updateWithUser:(LKUser *)user;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame maxHeight:(CGFloat)maxHeight;
- (instancetype)initWithFrame:(CGRect)frame maxHeight:(CGFloat)maxHeight minHeight:(CGFloat)minHeight;

-(void) handleScrollDidScroll:(UIScrollView *)scrollView;

@end
