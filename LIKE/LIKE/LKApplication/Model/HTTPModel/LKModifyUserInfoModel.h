//
//  LKModifyUserInfoModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/21.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"

LC_BLOCK(void, LKModifyUserInfoModelRequestFinished, (NSString * error));

@interface LKModifyUserInfoModel : LCHTTPRequestModel

+(void) setNewName:(NSString *)name requestFinished:(LKModifyUserInfoModelRequestFinished)requestFinished;

@end
