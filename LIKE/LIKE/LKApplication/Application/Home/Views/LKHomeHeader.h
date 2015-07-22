//
//  LKHomeHeader.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKSearchViewController.h"

@class FXBlurView;
@class LKSearchBar;

@interface LKHomeHeader : UIView

LC_PROPERTY(strong) LCUIImageView * headImageView;
LC_PROPERTY(strong) LCUILabel * nameLabel;
LC_PROPERTY(strong) LKSearchBar * textField;
LC_PROPERTY(strong) UIView * blurView;
LC_PROPERTY(strong) LCUIImageView * backgroundView;

LC_PROPERTY(copy) LKValueChanged willBeginSearch;
LC_PROPERTY(copy) LKValueChanged willEndSearch;

LC_PROPERTY(copy) LKValueChanged headAction;
LC_PROPERTY(copy) LKValueChanged backgroundAction;

LC_PROPERTY(weak) LKSearchViewController * searchViewController;

- (instancetype)initWithCGSize:(CGSize)size;

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;

-(void) updateWithUser:(LKUser *)user;

@end
