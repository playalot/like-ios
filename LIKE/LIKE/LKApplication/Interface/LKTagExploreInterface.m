//
//  LKTagExploreInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagExploreInterface.h"
#import "LKPost.h"

@implementation LKTagExploreInterface

- (NSString *)requestUrl {
    if (self.tagValue) {
        return [NSString stringWithFormat:@"/v1/explore/tag/%@", self.tagValue];
    }
    return nil;
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

- (NSArray *)users {
    NSArray * usersDic = self.responseJSONObject[@"data"][@"hot_users"];
    NSMutableArray * users = [NSMutableArray array];
    for (NSDictionary * user in usersDic) {
        [users addObject:[LKUser objectFromDictionary:user]];
    }
    return users;
}

- (NSArray *)posts {
    NSArray * postsDic = self.responseJSONObject[@"data"][@"posts"];
    NSMutableArray * posts = [NSMutableArray array];
    for (NSDictionary * post in postsDic) {
        [posts addObject:[LKPost objectFromDictionary:post]];
    }
    return posts;
}

@end

