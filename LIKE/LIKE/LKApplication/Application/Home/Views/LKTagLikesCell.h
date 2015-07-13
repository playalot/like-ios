//
//  LKTagLikesCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKTag.h"


@interface LKTagLikesCell : LCUITableViewCell

LC_PROPERTY(strong) LKTag * tagValue;
LC_PROPERTY(strong) NSArray * likes;

-(void) setTagValue:(LKTag *)tagValue andLikes:(NSArray *)likes;

LC_ST_SIGNAL(PushUserInfo);

@end

