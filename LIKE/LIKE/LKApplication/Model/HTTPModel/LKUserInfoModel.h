//
//  LKUserInfoModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"

LC_BLOCK(void, LKUserInfoModelRequestFinished, (LKHttpRequestResult * result, NSString * error));

@interface LKUserInfoModel : LCHTTPRequestModel

LC_PROPERTY(strong) LKUser * user;
LC_PROPERTY(strong) NSMutableDictionary * rawUserInfo;
LC_PROPERTY(copy) LKUserInfoModelRequestFinished requestFinished;

-(void) getUserInfo:(NSNumber *)uid;

@end