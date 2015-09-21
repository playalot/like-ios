//
//  LKBaseInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"
#import "LKUserDefaults.h"

@implementation LKBaseInterface

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSString *sessionToken = LKLocalUser.singleton.sessionToken;
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    if (sessionToken) {
        [resultDic setValue:sessionToken forKey:@"LIKE-SESSION-TOKEN"];
    }
    return resultDic;
}

@end
