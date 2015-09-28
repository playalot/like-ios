//
//  LKUserInfoModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserInfoModel.h"
#import "LKUserInfoCache.h"

@implementation LKUserInfoModel

-(void) dealloc
{
    [self cancelAllRequests];
}

-(void) getUserInfo:(NSNumber *)uid
{
    [self cancelAllRequests];
 
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:LC_NSSTRING_FORMAT(@"user/%@",uid)].AUTO_SESSION();
    
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            self.rawUserInfo = [result.json[@"data"] mutableCopy];
            self.user = [LKUser objectFromDictionary:self.rawUserInfo];
            
            //
            if (self.user.id.integerValue == LKLocalUser.singleton.user.id.integerValue) {
                
                [LKLocalUser.singleton updateCurrentUserInfo:self.rawUserInfo];
            }
            
            // cache...
            LKUserInfoCache.singleton[self.user.id.description] = self.rawUserInfo;
            
            if (self.requestFinished) {
                self.requestFinished(result, nil);
            }
        }
        else if (result.state == LKHttpRequestStateFailed){
           
            if (self.requestFinished) {
                self.requestFinished(result, result.error);
            }
        }
    }];
}

@end
