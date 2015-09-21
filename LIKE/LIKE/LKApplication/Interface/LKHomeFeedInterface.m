//
//  LKHomeFeedInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHomeFeedInterface.h"

@implementation LKHomeFeedInterface

- (NSString *)requestUrl {
    return @"/v1/homeFeeds";
}

- (id)requestArgument {
    if (self.timestamp)
        return @{@"ts": self.timestamp};
    return nil;
}

- (NSNumber *)next {
    return self.responseJSONObject[@"data"][@"next"];
}

- (NSArray *)posts {
    return self.responseJSONObject[@"data"][@"posts"];
}

@end
