//
//  LKContext.m
//  LIKE
//
//  Created by huangweifeng on 9/6/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKContext.h"

@implementation LKContext

+ (id)sharedInstance {
    static LKContext* _sharedInstance;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

@end
