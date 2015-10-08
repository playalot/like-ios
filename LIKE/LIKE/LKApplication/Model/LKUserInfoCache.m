//
//  LKUserInfoCache.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserInfoCache.h"

@implementation LKUserInfoCache

-(instancetype) init {
    if (self = [super initWithPath:[[LCSanbox documentPath] stringByAppendingString:@"/LKUserInfoCache.db"]]) {
        
    }
    
    return self;
}

-(id) objectForKeyedSubscript:(id)key
{
    id value = [super objectForKey:key];
    
    if (value) {
        return [[LKUser alloc] initWithDictionary:value error:nil];
    }
    
    return nil;
}

-(id) objectForKey:(NSString *)key
{
    id value = [super objectForKey:key];
    
    if (value) {
        return [[LKUser alloc] initWithDictionary:value error:nil];
    }
    
    return nil;
}


@end
