//
//  LKTagCommentCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/28.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKComment.h"

@interface LKTagCommentCell : LCUITableViewCell

LC_PROPERTY(strong) LKComment * comment;

+(CGFloat) height:(LKComment *)comment;

LC_ST_SIGNAL(PushUserCenter);

@end
