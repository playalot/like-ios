//
//  LKTopSearchInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTopSearchInterface.h"
#import "LKUser.h"

@implementation LKTopSearchInterface

- (instancetype)initWithSearchString:(NSString *)searchString {
    self = [super init];
    if (self) {
        self.searchString = searchString;
    }
    return self;
}

- (NSString *)requestUrl {
    if (self.searchString) {
        return [NSString stringWithFormat:@"/v1/search/topsearch/%@", self.searchString];
    }
    return nil;
}

- (NSArray *)users {
    NSArray * array = self.responseJSONObject[@"data"][@"users"];
    NSMutableArray * users = [NSMutableArray array];
    for (NSDictionary * dic in array) {
        [users addObject:[LKUser objectFromDictionary:dic]];
    }
    return users;
}

- (NSArray *)tags {
    NSArray * array = self.responseJSONObject[@"data"][@"tags"];
    NSMutableArray * tags = [NSMutableArray array];
    for (NSDictionary * dic in array) {
        LKTag * tag = [LKTag objectFromDictionary:dic];
        [tags addObject:tag];
    }
    return tags;
}

@end
