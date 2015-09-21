//
//  LKFollowingInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFollowingInterface.h"

@implementation LKFollowingInterface

- (NSString *)requestUrl {
    return @"/v1/followingFeeds";
}

- (id)requestArgument {
    if (self.timestamp) {
        return @{@"ts": self.timestamp};
    }
    return nil;
}

- (NSNumber *)next {
    return self.responseJSONObject[@"data"][@"next"];
}

- (NSArray *)posts {
    return self.responseJSONObject[@"data"][@"posts"];
}

- (NSDictionary *)responseObject {
    return self.responseJSONObject;
}

@end
