//
//  LKNotificationViewController.h
//  LIKE
//
//  Created by huangweifeng on 9/14/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUIViewController.h"
#import "LKNotificationModel.h"

@interface LKNotificationViewController : LCUIViewController

LC_PROPERTY(strong) LKNotificationModel *notificationModel;

- (void)refresh;

@end
