//
//  LKTagAddModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagAddModel.h"

@implementation LKTagAddModel

+(void) addTagString:(NSString *)tag onPost:(LKPost *)post requestFinished:(LKTagAddModelRequestFinished)requestFinished
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:LC_NSSTRING_FORMAT(@"post/%@/mark", post.id)].AUTO_SESSION().POST_METHOD();
    interface.jsonFormat = YES;
    interface.customAPIURL = LK_API2;
    
    [interface addParameter:tag key:@"tag"];
    
    
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
