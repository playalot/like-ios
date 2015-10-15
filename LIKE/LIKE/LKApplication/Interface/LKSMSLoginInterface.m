//
//  LKSMSLoginInterface.m
//  LIKE
//
//  Created by huangweifeng on 10/15/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSMSLoginInterface.h"

@implementation LKSMSLoginInterface

- (NSString *)sessionToken {
    return self.responseJSONObject[@"data"][@"session_token"];
}

- (NSString *)refreshToken {
    return self.responseJSONObject[@"data"][@"refresh_token"];
}

- (NSString *)expiresIn {
    return self.responseJSONObject[@"data"][@"expires_in"];
}

- (NSString *)userId {
    return self.responseJSONObject[@"data"][@"user_id"];
}

- (NSString *)requestUrl {
    return @"/v1/authenticate/mobile/ios";
}

- (id)requestArgument {
    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    if (self.zone) {
        [arguments setValue:self.zone forKey:@"zone"];
    }
    if (self.mobile) {
        [arguments setValue:self.mobile forKey:@"mobile"];
    }
    if (self.code) {
        [arguments setValue:self.code forKey:@"code"];
    }
    return arguments;
}

@end
