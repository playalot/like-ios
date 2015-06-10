//
//  LCHTTPRequestModel.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCHTTPRequestModel.h"

@interface LCHTTPRequestModel ()

@end

@implementation LCHTTPRequestModel

-(void) dealloc
{
    [self cancelAllRequests];
}

-(BOOL) saveResponse:(id)response key:(NSString *)key
{
    LCUserDefaults.DB[key] = response;
    return YES;
}

-(id) getResponseCache:(NSString *)key
{
    return LCUserDefaults.DB[key];
}

@end
