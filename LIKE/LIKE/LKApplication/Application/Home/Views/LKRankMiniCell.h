//
//  LKRankMiniCell.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/20.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKRank.h"

@interface LKRankMiniCell : LCUITableViewCell

LC_PROPERTY(strong) LKRank *rank;

LC_ST_SIGNAL(PushUserCenter);

@end
