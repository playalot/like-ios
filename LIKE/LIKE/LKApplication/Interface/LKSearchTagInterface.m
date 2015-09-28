//
//  LKSearchTagInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/28/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchTagInterface.h"
#import "LKTag.h"
#import "LKPost.h"

@implementation LKSearchTagInterface

- (instancetype)initWithSearchString:(NSString *)searchString {
    self = [super init];
    if (self) {
        self.searchString = searchString;
    }
    return self;
}

- (id)requestArgument {
    if (self.timestamp) {
        return @{@"ts": self.timestamp};
    }
    return nil;
}

- (NSString *)requestUrl {
    if (self.searchString) {
        return [NSString stringWithFormat:@"/v1/search/tag/%@", self.searchString];
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

@end
