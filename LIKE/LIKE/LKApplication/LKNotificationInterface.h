//
//  LKNotificationInterface.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKNotificationInterface : LKBaseInterface

LC_PROPERTY(assign) NSInteger timestamp;
LC_PROPERTY(assign) BOOL firstPage;

- (NSArray *)notifications;
- (instancetype)initWithTimestamp:(NSInteger)timestamp firstPage:(BOOL)firstPage;

@end
