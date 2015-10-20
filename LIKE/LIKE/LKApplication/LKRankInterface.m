//
//  LKRankInterface.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/19.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRankInterface.h"
#import "LKRank.h"

@implementation LKRankInterface

- (NSString *)requestUrl {
    return @"/v1/rank/today";
}

- (NSArray *)ranks {
    NSArray *ranksArray = self.responseJSONObject[@"data"][@"ranks"];
    NSMutableArray *ranks = [NSMutableArray array];
    for (NSDictionary *rank in ranksArray) {
        [ranks addObject:[LKRank objectFromDictionary:rank]];
    }
    return ranks;
}

@end
