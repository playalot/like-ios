//
//  LKNotificationModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"
#import "LKNotification.h"

typedef NS_ENUM(NSInteger, LKNotificationModelType)
{
    LKNotificationModelTypeLike,
    LKNotificationModelTypeFollow,
    LKNotificationModelTypeMessage,
    LKNotificationModelTypeOther
};

LC_BLOCK(void, LKNotificationModelRequestFinished, (NSString * error));

@interface LKNotificationModel : LCHTTPRequestModel

LC_PROPERTY(assign) NSInteger timestamp;
LC_PROPERTY(assign) NSInteger likeTimestamp;
LC_PROPERTY(assign) NSInteger followTimestamp;
LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) NSMutableArray *likesArray;
LC_PROPERTY(strong) NSMutableArray *followsArray;

-(void) getNotificationsAtFirstPage:(BOOL)firstPage requestFinished:(LKNotificationModelRequestFinished)requestFinished type:(LKNotificationModelType)type;

@end
