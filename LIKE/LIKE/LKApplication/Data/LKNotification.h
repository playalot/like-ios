//
//  LKNotification.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCDataModel.h"
#import "LKPost.h"

typedef NS_ENUM(NSInteger, LKNotificationType)
{
    LKNotificationTypeNewTag,
    LKNotificationTypeLikeTag,
    LKNotificationTypeFocus,
    LKNotificationTypeReply,
    LKNotificationTypeComment,
    LKNotificationTypeUpdate,
    LKNotificationTypeOfficial
};

@interface LKNotification : LCDataModel

LC_PROPERTY(assign) LKNotificationType type;
LC_PROPERTY(strong) LKUser *user;

LC_PROPERTY(strong) LKPost *post;
LC_PROPERTY(strong) NSMutableArray *posts;

LC_PROPERTY(strong) NSNumber *timestamp;
LC_PROPERTY(copy) NSString *tag;
LC_PROPERTY(strong) NSMutableArray *tags;
LC_PROPERTY(strong) NSNumber *tagID;

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err;

@end
