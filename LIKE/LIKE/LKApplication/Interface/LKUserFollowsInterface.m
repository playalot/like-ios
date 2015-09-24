//
//  LKUserFollowsInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/23/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserFollowsInterface.h"

@implementation LKUserFollowsInterface

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
    return [NSString stringWithFormat:@"/v1/user/%@/follows/%ld", self.uid, self.page
            ];
}

- (NSArray *)follows {
    NSArray *postsDic = self.responseJSONObject[@"data"][@"follows"];
    NSMutableArray *posts = [NSMutableArray array];
    for (NSDictionary *post in postsDic) {
        [posts addObject:[LKUser objectFromDictionary:post]];
    }
    return posts;
}

@end