//
//  LKLikeRecommendInterface.m
//  LIKE
//
//  Created by huangweifeng on 10/16/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLikeRecommendInterface.h"

@implementation LKLikeRecommendInterface

- (id)requestArgument {
    if (self.timestamp) {
        return @{@"ts": self.timestamp};
    }
    return nil;
}

- (NSString *)requestUrl {
    return @"/v1/explore/editorpick";
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

- (NSDictionary *)info {
    return self.responseJSONObject[@"data"][@"info"];
}


@end
