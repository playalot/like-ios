//
//  LKFriendshipModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFriendshipModel.h"

@implementation LKFriendshipModel

+(void) friendshipAction:(LKUser *)user requestFinished:(LKFriendshipModelRequestFinished)requestFinished
{
    switch (user.isFollowing.integerValue) {
        case 0:
            
            //
            [LKFriendshipModel focusUser:user requestFinished:requestFinished];
            
            break;
        case 1:
            
            [LKFriendshipModel unfocusUser:user requestFinished:requestFinished];

            break;
        case 2:
            
            [LKFriendshipModel unfocusUser:user requestFinished:requestFinished];

            break;
    }
}

+(void) focusUser:(LKUser *)user requestFinished:(LKFriendshipModelRequestFinished)requestFinished
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"user/%@/follow", user.id]].AUTO_SESSION().POST_METHOD();
    interface.customAPIURL = LK_API2;
    interface.jsonFormat = YES;
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        if (result.state == LKHttpRequestStateFinished) {
            
            
            user.isFollowing = result.json[@"data"][@"is_following"];

            if (requestFinished) {
                requestFinished(user.isFollowing, nil);
            }
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            if (requestFinished) {
                requestFinished(user.isFollowing, result.error);
            }
        }
        
    }];
}

+(void) unfocusUser:(LKUser *)user requestFinished:(LKFriendshipModelRequestFinished)requestFinished
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"user/%@/follow", user.id]].AUTO_SESSION().DELETE_METHOD();

    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        if (result.state == LKHttpRequestStateFinished) {
            
            user.isFollowing = @(0);
            
            if (requestFinished) {
                requestFinished(@(0), nil);
            }
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            if (requestFinished) {
                requestFinished(user.isFollowing, result.error);
            }
        }
        
    }];
}

@end
