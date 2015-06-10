//
//  NSObject+LCHTTPRequest.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "NSObject+LCHTTPRequest.h"
#import "LCNetworkCenter.h"

@implementation NSObject (LCHTTPRequest)

- (LCHTTPRequestBlockSN)GET
{
    LCHTTPRequestBlockSN block = ^ NSURLSessionDataTask * (NSString * url, LCNetworkCenterBlock update)
    {
        return [LCNetworkCenter requestURL:url method:LCHTTPRequestMethodGet customManager:nil parameters:nil sender:self updateBlock:update];
    };
    
    return block;
}

- (LCHTTPRequestBlockSN)PUT
{
    LCHTTPRequestBlockSN block = ^ NSURLSessionDataTask * (NSString * url, LCNetworkCenterBlock update)
    {
        return [LCNetworkCenter requestURL:url method:LCHTTPRequestMethodPut customManager:nil parameters:nil sender:self updateBlock:update];
    };
    
    return block;
}

- (LCHTTPRequestBlockSN)POST
{
    LCHTTPRequestBlockSN block = ^ NSURLSessionDataTask * (NSString * url, LCNetworkCenterBlock update)
    {
        return [LCNetworkCenter requestURL:url method:LCHTTPRequestMethodPost customManager:nil parameters:nil sender:self updateBlock:update];
    };
    
    return block;
}

- (LCHTTPRequestBlockSN)DELETE
{
    LCHTTPRequestBlockSN block = ^ NSURLSessionDataTask * (NSString * url, LCNetworkCenterBlock update)
    {
        return [LCNetworkCenter requestURL:url method:LCHTTPRequestMethodDelete customManager:nil parameters:nil sender:self updateBlock:update];
    };
    
    return block;
}

- (void)cancelAllRequests
{
    [LCNetworkCenter cancelRequestsWithObject:self];
}

@end
