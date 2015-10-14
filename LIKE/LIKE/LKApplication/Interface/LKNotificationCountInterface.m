//
//  LKNotificationCountInterface.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/9.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationCountInterface.h"

@implementation LKNotificationCountInterface

- (NSString *)requestUrl {
    return @"/v1/notification/count";
}

- (NSInteger)count {
    return [self.responseJSONObject[@"data"][@"count"] integerValue];
}

@end
