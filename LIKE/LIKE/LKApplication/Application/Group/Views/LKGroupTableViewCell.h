//
//  LKGroupTableViewCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/9/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKPost.h"

@interface LKGroupTableViewCell : LCUITableViewCell

LC_PROPERTY(strong) LKPost *post;

+(CGFloat) height:(LKPost *)post;

@end
