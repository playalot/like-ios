//
//  LCNetworkCenter.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/5.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSUInteger, LCHTTPRequestMethod) {
    LCHTTPRequestMethodGet = 0,
    LCHTTPRequestMethodHead,
    LCHTTPRequestMethodPost,
    LCHTTPRequestMethodPut,
    LCHTTPRequestMethodPatch,
    LCHTTPRequestMethodDelete,
};

@interface NSObject (LCNetworkTagString)

LC_PROPERTY(strong) NSString * _TagString_;

@end

@interface LCHTTPRequestResult : NSObject

LC_PROPERTY(strong) NSURLSessionDataTask * task;
LC_PROPERTY(strong) NSError * error;
LC_PROPERTY(strong) id responseObject;

@end

LC_BLOCK(void, LCNetworkCenterBlock, (LCHTTPRequestResult * result));


@interface LCNetworkCenter : NSObject

LC_PROPERTY(strong) AFHTTPSessionManager * sessionManager;
LC_PROPERTY(strong) NSMutableDictionary * requests;

+(NSURLSessionDataTask *) requestURL:(NSString *)url
                              method:(LCHTTPRequestMethod)method
                       customManager:(AFHTTPSessionManager *)customManager
                          parameters:(id)parameters
                              sender:(NSObject *)sender
                         updateBlock:(LCNetworkCenterBlock)updateBlock;

+ (void)cancelRequestsWithObject:(NSObject *)object;
- (void)cancelRequestsWithObject:(NSObject *)object;

@end
