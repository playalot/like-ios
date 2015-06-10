//
//  LCNetwork.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCNetwork.h"

@implementation LCNetwork

+(void) load
{
    //[LCNetwork singleton];
}

-(instancetype) init
{
    if (self = [super init]) {
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            _netWorkStatus = (LCNetworkStatus)status;
        }];
    }
    
    return self;
}

-(BOOL) isWiFi
{
    return self.netWorkStatus == LCNetworkStatusViaWiFi;
}

-(BOOL) isOffline
{
    return self.netWorkStatus == LCNetworkStatusUnknow || self.netWorkStatus == LCNetworkStatusNotReachable;
}

@end
