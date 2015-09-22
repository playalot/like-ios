//
//  LKNormalOfficialCell.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"

@interface LKNormalOfficialCell : LCUITableViewCell

LC_PROPERTY(strong) LCUILabel *titleLbl;
LC_PROPERTY(strong) LCUILabel *subTitleLbl;
LC_PROPERTY(strong) LCUIView *cellBackgroundView;
LC_PROPERTY(strong) LCUIImageView *iconView;
LC_PROPERTY(assign) CGFloat cellHeight;

@end
