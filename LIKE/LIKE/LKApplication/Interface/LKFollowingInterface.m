//
//  LKFollowingInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFollowingInterface.h"

@implementation LKFollowingInterface

- (instancetype)initWithNext:(NSNumber *)next {
    self = [super init];
    if (self) {
        self.next = next;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/v1/followingFeeds";
}

- (id)requestArgument {
    if (self.next)
        return @{@"ts": self.next};
    return nil;
}

- (NSNumber *)next {
    return self.responseJSONObject[@"data"][@"next"];
}

- (NSArray *)posts {
    return self.responseJSONObject[@"data"][@"posts"];
}


@end
