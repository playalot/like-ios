//
//  LKNotificationInterface.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationInterface.h"

@implementation LKNotificationInterface

- (instancetype)initWithTimestamp:(NSInteger)timestamp firstPage:(BOOL)firstPage {
    
    if (self = [super init]) {
        
        self.timestamp = timestamp;
        self.firstPage = firstPage;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/v2/notification";
}

- (NSArray *)notifications {
    
    return self.responseJSONObject[@"data"][@"notifications"];
}

- (id)requestArgument {
    
    if (self.timestamp && !self.firstPage)
        return @{@"ts": @(self.timestamp)};
    return nil;
}

@end
