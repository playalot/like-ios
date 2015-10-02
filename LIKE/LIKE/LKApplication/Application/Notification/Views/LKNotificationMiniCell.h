//
//  LKNotificationMiniCell.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/29.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUITableViewCell.h"
#import "LKNotification.h"

@interface LKNotificationMiniCell : LCUITableViewCell

LC_PROPERTY(strong) LKNotification * notification;
LC_PROPERTY(assign) CGFloat cellHeight;

+ (CGFloat)height:(LKNotification *)notification;

LC_ST_SIGNAL(PushPostDetail);
LC_ST_SIGNAL(PushUserCenter);

@end
