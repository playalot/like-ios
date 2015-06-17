//
//  LKModifyUserInfoModel.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKModifyUserInfoModel.h"

@implementation LKModifyUserInfoModel

+(void) setNewName:(NSString *)name requestFinished:(LKModifyUserInfoModelRequestFinished)requestFinished
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"user/nickname"].AUTO_SESSION().PUT_METHOD();
    
    [interface addParameter:name key:@"nickname"];
    
    [LC_KEYWINDOW showTopLoadingMessageHud:LC_LO(@"修改中...")];
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        if (result.state == LKHttpRequestStateFinished) {
            
            [RKDropdownAlert dismissAllAlert];

            requestFinished(nil);
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [RKDropdownAlert dismissAllAlert];
            [LC_KEYWINDOW showTopMessageErrorHud:result.error];
            
            requestFinished(result.error);
        }
        
    }];
}



@end
