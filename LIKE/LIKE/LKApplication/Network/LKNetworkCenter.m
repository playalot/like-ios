//
//  IFNetworkCenter.m
//  IFAPP
//
//  Created by Leer on 14/12/30.
//  Copyright (c) 2014年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "LKNetworkCenter.h"
#import "LKHttpRequestInterface.h"
#import "LKNetwork.h"
#import "AppDelegate.h"
#import "LCNetworkCenter.h"

#import "AFNetworking.h"

@interface LKNetworkCenter ()

@end

@implementation LKNetworkCenter

- (instancetype)init {
    if (self = [super init]) {
        
        [self addDefaultHeaderForURLSessionManager:LCNetworkCenter.singleton.sessionManager];
        
    }
    
    return self;
}

+ (BOOL)request:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete {
    return [LKNetworkCenter.singleton request:interface sender:sender complete:complete];
}

- (BOOL)request:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete {
    NSString * sesstionToken = LKLocalUser.singleton.sessionToken;

    [LCNetworkCenter.singleton.sessionManager.requestSerializer setValue:sesstionToken forHTTPHeaderField:@"LIKE-SESSION-TOKEN"];
    [LCNetworkCenter.singleton.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *url = nil;
    
    if ([interface.type rangeOfString:@"notification"].location != NSNotFound) {
        
        url = [[LK_API stringByReplacingOccurrencesOfString:@"v1" withString:@"v2"] stringByAppendingString:interface.type];
    } else {
        
        url = [LK_API stringByAppendingString:interface.type];
    }
    
    [LCNetworkCenter requestURL:url
                         method:interface.methodType
                  customManager:nil
                     parameters:interface.interfaceParameters
                         sender:sender
                    updateBlock:^(LCHTTPRequestResult *result) {
        [self handleUpdate:result complete:complete];
    }];
    
    return YES;
}

-(void) handleUpdate:(LCHTTPRequestResult *)requestResult complete:(LKHTTPRequestComplete)complete
{
    if (!requestResult.error) {
        
        // Build a result object.
        LKHttpRequestResult * result = [LKHttpRequestResult result];
        
        // Interface retun this object.
        NSDictionary * returnObject = requestResult.responseObject;
        
        NSInteger errCode = -1;
        
        NSNumber * errCodeNumber = returnObject[@"code"];
        
        if (errCodeNumber) {
            errCode = [errCodeNumber integerValue];
        }
        
        if (errCode == 1) {
            
            result.state = LKHttpRequestStateFinished;
            result.json = returnObject;
            result.errorCode = @(1);
            
            NSString * errMessage = returnObject[@"message"];
            
            if (!errMessage) {
                errMessage = @"✅";
            }
            
            result.error = errMessage;
            
            complete(result);
            
        }else{
            
            NSString * errMessage = returnObject[@"message"];
            
            if (!errMessage || errMessage.length == 0) {
                
                errMessage = LC_NSSTRING_FORMAT(@"Some error occurred%@, but there's no description about it.", returnObject[@"code"] ? [NSString stringWithFormat:@"(%@)", returnObject[@"code"]] : @"");
            }
            else{
                
                //errMessage = [NSString stringWithFormat:@"%@ (%@)",returnObject[@"message"], returnObject[@"code"]];
            }
            
            result.state = LKHttpRequestStateFailed;
            result.json = nil;
            result.errorCode = errCodeNumber;
            result.error = errMessage;
            
            complete(result);
            
            // 授权过期
            if (errCode == 4016 || errCode == 4013) {
                
                if (LKLocalUser.singleton.isLogin) {
                    
                    [self postNotification:LKSessionError withObject:@(errCode)];
                }
            }
        }
        
    }else{
    
        LKHttpRequestResult * result = [LKHttpRequestResult result];

        if (requestResult.error.code == -999) {
            
            result.state = LKHttpRequestStateCanceled;
        }
        else{
         
            result.state = LKHttpRequestStateFailed;
        }
        
 
        result.json = nil;
        result.errorCode = @(requestResult.error.code);
        result.error = requestResult.error.localizedDescription;
        
        complete(result);
    }
}

-(void) addDefaultHeaderForURLSessionManager:(AFHTTPSessionManager *)manager
{
    //
    NSString * country = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    
    [manager.requestSerializer setValue:country forHTTPHeaderField:@"Accept-Language"];
    
    CGFloat width = LC_DEVICE_WIDTH * (UI_IS_IPHONE6PLUS ? 3 : 2);
    
    [manager.requestSerializer setValue:@(width).description forHTTPHeaderField:@"LIKE-SCREEN-WIDTH"];
//    [manager.requestSerializer setValue:country forHTTPHeaderField:@"LIKE-LANGUAGE"];
    
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    // 获取当前App版本号
    NSString *appVersion = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];

    [manager.requestSerializer setValue:appVersion forHTTPHeaderField:@"LIKE-VERSION"];
    
    if (LCNetwork.singleton.netWorkStatus == LCNetworkStatusViaWiFi) {
        
        [manager.requestSerializer setValue:@"YES" forHTTPHeaderField:@"LIKE-WIFI"];
    }
}

@end
