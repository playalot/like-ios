//
//  LKFollowingFeedInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFollowingFeedInterface.h"
#import "LKPost.h"

@implementation LKFollowingFeedInterface

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
    NSArray *resultData = self.responseJSONObject[@"data"][@"posts"];
    NSMutableArray * datasource = [NSMutableArray array];
    for (NSDictionary * tmp in resultData) {
        [datasource addObject:[LKPost objectFromDictionary:tmp]];
    }
    return datasource;
}

- (NSDictionary *)responseObject {
    return self.responseJSONObject;
}

@end
