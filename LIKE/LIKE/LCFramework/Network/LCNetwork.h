//
//  LCNetwork.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "AFNetworkReachabilityManager.h"
#import "NSObject+LCHTTPRequest.h"
#import "LCNetworkCenter.h"

typedef NS_ENUM(NSInteger, LCNetworkStatus)
{
    LCNetworkStatusUnknow = AFNetworkReachabilityStatusUnknown,
    LCNetworkStatusNotReachable = AFNetworkReachabilityStatusNotReachable,
    LCNetworkStatusViaWWAN = AFNetworkReachabilityStatusReachableViaWWAN,   // 3G
    LCNetworkStatusViaWiFi = AFNetworkReachabilityStatusReachableViaWiFi,
};

@interface LCNetwork : NSObject

LC_PROPERTY(readonly) LCNetworkStatus netWorkStatus;

-(BOOL) isWiFi;
-(BOOL) isOffline;

@end
