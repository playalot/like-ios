//
//  LCNetworkCenter.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/5.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCNetworkCenter.h"
#import "AFNetworkActivityIndicatorManager.h"

NSString * LCHTTPRequestMethodString(LCHTTPRequestMethod method)
{
    NSString * methodString = nil;
    switch (method) {
        case LCHTTPRequestMethodGet:
            methodString = @"GET";
            break;
        case LCHTTPRequestMethodHead:
            methodString = @"HEAD";
            break;
        case LCHTTPRequestMethodPost:
            methodString = @"POST";
            break;
        case LCHTTPRequestMethodPut:
            methodString = @"PUT";
            break;
        case LCHTTPRequestMethodPatch:
            methodString = @"PATCH";
            break;
        case LCHTTPRequestMethodDelete:
            methodString = @"DELETE";
            break;
    }
    return methodString;
}

@implementation LCHTTPRequestResult

@end

@interface NSURLSessionTask (LCTagString)

LC_PROPERTY(copy) NSString * tagString;

@end

@implementation NSURLSessionTask (LCTagString)

-(void) setTagString:(NSString *)tagString
{
    [LCAssociate setAssociatedObject:self value:tagString key:@"NSURLSessionTaskTagString"];
}

-(NSString *) tagString
{
    return [LCAssociate getAssociatedObject:self key:@"NSURLSessionTaskTagString"];
}

@end

@interface LCNetworkCenter ()

LC_PROPERTY(strong) NSLock * lock;

@end

@implementation LCNetworkCenter

-(instancetype) init
{
    if (self = [super init]) {
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        self.sessionManager = [AFHTTPSessionManager manager];
        self.requests = [NSMutableDictionary dictionary];
        self.lock = [[NSLock alloc] init];
    }
    
    return self;
}

+(NSURLSessionDataTask *) requestURL:(NSString *)url
                              method:(LCHTTPRequestMethod)method
                       customManager:(AFHTTPSessionManager *)customManager
                          parameters:(id)parameters
                              sender:(NSObject *)sender
                         updateBlock:(LCNetworkCenterBlock)updateBlock
{
    return [LCNetworkCenter.singleton requestURL:url
                                          method:method
                                   customManager:customManager
                                      parameters:parameters
                                          sender:sender
                                     updateBlock:updateBlock];
};

-(NSURLSessionDataTask *) requestURL:(NSString *)url
                              method:(LCHTTPRequestMethod)method
                       customManager:(AFHTTPSessionManager *)customManager
                          parameters:(id)parameters
                              sender:(NSObject *)sender
                         updateBlock:(LCNetworkCenterBlock)updateBlock
{
    AFHTTPSessionManager * manager = self.sessionManager;
    
    if (customManager) {
        manager = customManager;
    }
    
    NSURLSessionDataTask * task = nil;
    
    switch (method) {
        case LCHTTPRequestMethodGet:
        {
            task = [manager GET:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [self handleSuccessTask:task responseOjbect:responseObject updateBlock:updateBlock sender:sender];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [self handleFailureTask:task error:error updateBlock:updateBlock sender:sender];
            }];
        }
            break;
        case LCHTTPRequestMethodHead:
        {
            task = [manager HEAD:url parameters:parameters success:^(NSURLSessionDataTask *task) {
                
                [self handleSuccessTask:task responseOjbect:nil updateBlock:updateBlock sender:sender];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [self handleFailureTask:task error:error updateBlock:updateBlock sender:sender];
            }];
        }
            break;
        case LCHTTPRequestMethodPost:
        {
            task = [manager POST:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [self handleSuccessTask:task responseOjbect:responseObject updateBlock:updateBlock sender:sender];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [self handleFailureTask:task error:error updateBlock:updateBlock sender:sender];
            }];
        }
            break;
        case LCHTTPRequestMethodPut:
        {
            task = [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [self handleSuccessTask:task responseOjbect:responseObject updateBlock:updateBlock sender:sender];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [self handleFailureTask:task error:error updateBlock:updateBlock sender:sender];
            }];
        }
            break;
        case LCHTTPRequestMethodPatch:
        {
            task = [manager PATCH:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [self handleSuccessTask:task responseOjbect:responseObject updateBlock:updateBlock sender:sender];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [self handleFailureTask:task error:error updateBlock:updateBlock sender:sender];
            }];
        }
            break;
        case LCHTTPRequestMethodDelete:
        {
            task = [manager DELETE:url parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
                
                [self handleSuccessTask:task responseOjbect:responseObject updateBlock:updateBlock sender:sender];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                [self handleFailureTask:task error:error updateBlock:updateBlock sender:sender];
            }];
        }
            break;
    }
    
    
    [self.lock lock];
    [self addTask:task withSender:sender];
    [self.lock unlock];
    
    return nil;
}

+(void) cancelRequestsWithObject:(NSObject *)object
{
    [LCNetworkCenter.singleton cancelRequestsWithObject:object];
}

-(void) cancelRequestsWithObject:(NSObject *)object
{
    [self.lock lock];
    NSURLSessionDataTask * task = [self getTaskWithSender:object];
    [self.lock unlock];
    
    if (task) {
        [task cancel];
    }
}

-(NSURLSessionDataTask *) getTaskWithSender:(NSObject *)sender
{
    NSString * p = LC_NSSTRING_FORMAT(@"LCNetworkCenter-%p",sender);
    
    NSMutableArray * subArray = self.requests[p];
    
    if (subArray && subArray.count) {
        
        for(NSURLSessionDataTask * task in subArray) {
            
            if ([task.tagString isEqualToString:p]) {
                
                return task;
            }
        }
    }
    
    return nil;
}

-(void) addTask:(NSURLSessionDataTask *)task withSender:(NSObject *)sender
{
    NSString * p = LC_NSSTRING_FORMAT(@"LCNetworkCenter-%p",sender);

    task.tagString = p;

    NSMutableArray * subArray = self.requests[p];
    
    if (!subArray) {
        
        subArray = [NSMutableArray array];
        [self.requests setObject:subArray forKey:p];
    }
    
    [subArray addObject:task];
}

-(void) removeTask:(NSURLSessionDataTask *)task withSender:(NSObject *)sender
{
    if (!task.tagString) {
        return;
    }
    
    NSString * p = LC_NSSTRING_FORMAT(@"LCNetworkCenter-%p",sender);
    
    NSMutableArray * subArray = self.requests[p];
    
    if (subArray.count == 0) {
        return;
    }
    
    [subArray removeObject:task];
    
    if (subArray.count == 0) {
        [self.requests removeObjectForKey:p];
    }
}

-(void) handleSuccessTask:(NSURLSessionDataTask *)task responseOjbect:(id)responseObject updateBlock:(LCNetworkCenterBlock)updateBlock sender:(NSObject *)sender
{
    LCHTTPRequestResult * result = [[LCHTTPRequestResult alloc] init];
    result.responseObject = responseObject;
    result.task = task;
    
    if (updateBlock) {
        updateBlock(result);
    }
    
    [self.lock lock];
    [self removeTask:task withSender:sender];
    [self.lock unlock];
}

-(void) handleFailureTask:(NSURLSessionDataTask *)task error:(NSError *)error updateBlock:(LCNetworkCenterBlock)updateBlock sender:(NSObject *)sender
{
    LCHTTPRequestResult * result = [[LCHTTPRequestResult alloc] init];
    result.error = error;
    result.task = task;
    
    if (updateBlock) {
        updateBlock(result);
    }
    
    
    [self.lock lock];
    [self removeTask:task withSender:sender];
    [self.lock unlock];
}



@end
