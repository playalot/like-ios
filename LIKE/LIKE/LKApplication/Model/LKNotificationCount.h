//
//  LKNotificationCount.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/24.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

LC_BLOCK(void, LKNotificationCountRequestFinished, (NSUInteger count));

@interface LKNotificationCount : NSObject

+(void) bindView:(UIView *)bindView;
+(void) bindView:(UIView *)bindView withBadgeCount:(NSInteger)badgeCount;
+(void) cleanBadge;

+(void) startCheck;
+(void) stopCheck;

LC_PROPERTY(copy) LKNotificationCountRequestFinished requestFinished;

@end
