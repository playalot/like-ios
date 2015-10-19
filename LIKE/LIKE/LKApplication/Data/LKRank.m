//
//  LKRank.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/19.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRank.h"

@implementation LKRank

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    
    if (self = [super init]) {
        
        if (dict == nil || [dict isKindOfClass:[NSDictionary class]]) {
            
            self.likes = dict[@"likes"];
            self.rank = dict[@"rank"];
            self.up = dict[@"up"];
            self.userId = dict[@"user_id"];
            self.user = [LKUser objectFromDictionary:dict[@"user"]];
        } else {
            
            ERROR(@"...");
        }
    }
    return self;
}

@end
