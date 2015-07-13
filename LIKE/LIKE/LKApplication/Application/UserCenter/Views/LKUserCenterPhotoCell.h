//
//  LKUserCenterPhotoCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKPost.h"

@interface LKUserCenterPhotoCell : LCUITableViewCell

LC_PROPERTY(strong) NSArray * posts; // Count : 3

+(CGFloat) height;

LC_ST_SIGNAL(PushPostDetail);

@end

