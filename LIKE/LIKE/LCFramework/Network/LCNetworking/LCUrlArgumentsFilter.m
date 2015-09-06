//
// Created by Chenyu Lan on 8/27/14.
// Copyright (c) 2014 Fenbi. All rights reserved.
//

#import "LCUrlArgumentsFilter.h"
#import "LCNetworkPrivate.h"

@implementation LCUrlArgumentsFilter {
    NSDictionary *_arguments;
}

+ (LCUrlArgumentsFilter *)filterWithArguments:(NSDictionary *)arguments {
    return [[self alloc] initWithArguments:arguments];
}

- (id)initWithArguments:(NSDictionary *)arguments {
    self = [super init];
    if (self) {
        _arguments = arguments;
    }
    return self;
}

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(LCBaseRequest *)request {
    return [LCNetworkPrivate urlStringWithOriginUrlString:originUrl appendParameters:_arguments];
}

@end
