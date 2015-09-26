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

- (instancetype)initWithUid:(NSNumber *)uid page:(NSInteger)page {
    self =  [super init];
    if (self) {
        self.uid = uid;
        self.page = page;
    }
    return self;
}

- (NSString *)requestUrl {
    if (!self.uid) return nil;
    return [NSString stringWithFormat:@"/v1/user/%@/posts/%ld", self.uid, self.page];
}

- (NSArray *)posts {
    NSArray *postsDic = self.responseJSONObject[@"data"][@"posts"];
    NSMutableArray *posts = [NSMutableArray array];
    for (NSDictionary *post in postsDic) {
        [posts addObject:[LKPost objectFromDictionary:post]];
    }
    return posts;
}

@end
