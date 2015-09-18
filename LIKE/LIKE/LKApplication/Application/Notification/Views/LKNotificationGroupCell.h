//
//  LKNotificationGroupCell.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"

@interface LKNotificationGroupCell : LCUITableViewCell

LC_PROPERTY(strong) LCUIImageView *iconView;
LC_PROPERTY(strong) LCUILabel *titleLbl;
LC_PROPERTY(strong) LCUIBadgeView *badgeView;

@end
