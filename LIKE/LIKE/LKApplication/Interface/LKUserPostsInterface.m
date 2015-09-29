//
//  LKUserPostsInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/23/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserPostsInterface.h"
#import "LKPost.h"

@implementation LKUserPostsInterface

- (instancetype)initWithTimeStamp:(NSNumber *)timestamp uid:(NSNumber *)uid {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.timestamp = timestamp;
    }
    return self;
}

- (NSString *)requestUrl {
    if (!self.uid) return nil;
    return [NSString stringWithFormat:@"/v1/user/%@/posts", self.uid];
}

- (id)requestArgument {
    if (self.timestamp)
        return @{@"ts": self.timestamp};
    return nil;
}

- (NSArray *)posts {
    NSArray *postsDic = self.responseJSONObject[@"data"][@"posts"];
    NSMutableArray *posts = [NSMutableArray array];
    for (NSDictionary *post in postsDic) {
        [posts addObject:[LKPost objectFromDictionary:post]];
    }
    return posts;
}

- (NSNumber *)next {
    return self.responseJSONObject[@"data"][@"next"];
}

@end
