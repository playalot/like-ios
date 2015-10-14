//
//  LKPostThumbnailTableViewCell.h
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"

@interface LKPostThumbnailTableViewCell : LCUITableViewCell

LC_PROPERTY(strong) NSArray *posts;

LC_ST_SIGNAL(PushPostDetail);

+ (CGFloat)height;

@end
