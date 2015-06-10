//
//  LKPostLikeModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagLikeModel.h"

@implementation LKTagLikeModel

+(void) likeOrUnLike:(LKTag *)tag requestFinished:(LKPostLikeModelRequestFinished)requestFinished
{
    LKHttpRequestInterface * interface = nil;
    
    if (!tag.isLiked) {
        
        interface = [LKHttpRequestInterface interfaceType:LC_NSSTRING_FORMAT(@"mark/%@/like", tag.id)].AUTO_SESSION().DELETE_METHOD();
        interface.jsonFormat = YES;
        interface.customAPIURL = LK_API2;
    }
    else{
        
        interface = [LKHttpRequestInterface interfaceType:LC_NSSTRING_FORMAT(@"mark/%@/like", tag.id)].AUTO_SESSION().POST_METHOD();
        interface.jsonFormat = YES;
        interface.customAPIURL = LK_API2;
    }
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        if (result.state == LKHttpRequestStateFinished) {
            
            if (requestFinished) {
                requestFinished(result, nil);
            }
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            if (requestFinished) {
                requestFinished(result, result.error);
            }
        }
        
    }];
}

@end
