//
//  LKNotificationBaseCell.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKNotification.h"

@interface LKNotificationCell : LCUITableViewCell

LC_PROPERTY(strong) LKNotification * notification;
LC_PROPERTY(assign) CGFloat cellHeight;
LC_PROPERTY(strong) LCUIImageView *preview;

+ (CGFloat)height:(LKNotification *)notification;

LC_ST_SIGNAL(PushPostDetail);
LC_ST_SIGNAL(PushUserCenter);

@end


