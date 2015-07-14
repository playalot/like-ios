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

-(instancetype) init
{
    if (self = [super init]) {
        
        [self addDefaultHeaderForURLSessionManager:LCNetworkCenter.singleton.sessionManager];
        
    }
    
    return self;
}

+(BOOL) request:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete
{
    return [LKNetworkCenter.singleton request:interface sender:sender complete:complete];
}

-(BOOL) request:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete
{
    NSString * sesstionToken = LKLocalUser.singleton.sessionToken;

    [LCNetworkCenter.singleton.sessionManager.requestSerializer setValue:sesstionToken forHTTPHeaderField:@"LIKE-SESSION-TOKEN"];
    [LCNetworkCenter.singleton.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    
    NSString * url = [LK_API stringByAppendingString:interface.type];
    
    [LCNetworkCenter requestURL:url
                         method:interface.methodType
                  customManager:nil
                     parameters:interface.interfaceParameters
                         sender:sender
                    updateBlock:^(LCHTTPRequestResult *result) {
       
        [self handleUpdate:result complete:complete];
        
    }];
    
//    switch (request.methodType) {
//            
//        case LKHttpRequestMethodTypeGet:
//            [self requestGet:request sender:sender complete:complete];
//            break;
//        case LKHttpRequestMethodTypePost:
//            [self requestPost:request sender:sender complete:complete];
//            break;
//        case LKHttpRequestMethodTypePut:
//            [self requestPut:request sender:sender complete:complete];
//            break;
//        case LKHttpRequestMethodTypeDelete:
//            [self requestDelete:request sender:sender complete:complete];
//            break;
//        default:
//            
//            return NO;
//            break;
//    }
    
    return YES;
}

//-(void) requestGet:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete
//{
//    NSDictionary * parameters = interface.interfaceParameters;
//    
//    NSString * url = [interface.customAPIURL ? interface.customAPIURL : LK_API stringByAppendingString:interface.type];
//
//    NSInteger i = 0;
//    
//    for (NSString * key in parameters.allKeys) {
//        
//        if (i == 0) {
//            
//            url = url.APPEND(@"?%@=%@",key,((NSString *)parameters[key]).URLCODE());
//        }
//        else{
//            
//            url = url.APPEND(@"&%@=%@",key,((NSString *)parameters[key]).URLCODE());
//        }
//        
//        i++;
//    }
//
//    
//    LCHTTPRequest * rawRequest = sender.GET(url);
//    
//    [self addDefaultHeader:rawRequest];
//
//    if (interface.sessionToken) {
//        rawRequest.HEADER(@"LIKE-SESSION-TOKEN", interface.sessionToken);
//    }
//    
//    rawRequest.UPDATE = ^(LCHTTPRequest * request){
//      
//        [self handleUpdate:request complete:complete];
//    };
//}
//
//-(void) requestPost:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete
//{
//    NSDictionary * parameters = interface.interfaceParameters;
//    
//    NSString * url = [interface.customAPIURL ? interface.customAPIURL : LK_API stringByAppendingString:interface.type];
//    
//    LCHTTPRequest * rawRequest = sender.POST(url);
//    
//    [self addDefaultHeader:rawRequest];
//
//    if (interface.sessionToken) {
//        rawRequest.HEADER(@"LIKE-SESSION-TOKEN", interface.sessionToken);
//    }
//    
//    if (interface.jsonFormat) {
//        
//        rawRequest.BODY(parameters.JSONString);
//    }
//    else{
//        
//        for (NSString * key in parameters.allKeys) {
//            
//            rawRequest.PARAM(key,parameters[key]);
//        }
//    }
//    
//    rawRequest.UPDATE = ^(LCHTTPRequest * request){
//        
//        [self handleUpdate:request complete:complete];
//    };
//}
//
//-(void) requestPut:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete
//{
//    NSDictionary * parameters = interface.interfaceParameters;
//    
//    NSString * url = [interface.customAPIURL ? interface.customAPIURL : LK_API stringByAppendingString:interface.type];
//    
//    LCHTTPRequest * rawRequest = sender.PUT(url);
//    
//    [self addDefaultHeader:rawRequest];
//
//    if (interface.sessionToken) {
//        rawRequest.HEADER(@"LIKE-SESSION-TOKEN", interface.sessionToken);
//    }
//    
//    for (NSString * key in parameters.allKeys) {
//        
//        rawRequest.PARAM(key,parameters[key]);
//    }
//    
//    rawRequest.UPDATE = ^(LCHTTPRequest * request){
//        
//        [self handleUpdate:request complete:complete];
//    };
//
//}
//
//-(void) requestDelete:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete
//{
//    NSDictionary * parameters = interface.interfaceParameters;
//    
//    NSString * url = [interface.customAPIURL ? interface.customAPIURL : LK_API stringByAppendingString:interface.type];
//    
//    LCHTTPRequest * rawRequest = sender.DELETE(url);
//    
//    [self addDefaultHeader:rawRequest];
//    
//    if (interface.sessionToken) {
//        rawRequest.HEADER(@"LIKE-SESSION-TOKEN", interface.sessionToken);
//    }
//    
//    for (NSString * key in parameters.allKeys) {
//        
//        rawRequest.PARAM(key,parameters[key]);
//    }
//    
//    rawRequest.UPDATE = ^(LCHTTPRequest * request){
//        
//        [self handleUpdate:request complete:complete];
//    };
//}

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
                
                [self postNotification:LKSessionError withObject:@(errCode)];
            }
        }
        
    }else{
    
        LKHttpRequestResult * result = [LKHttpRequestResult result];
        result.state = LKHttpRequestStateFailed;
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
    [manager.requestSerializer setValue:country forHTTPHeaderField:@"LIKE-LANGUAGE"];
    
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
}

@end
