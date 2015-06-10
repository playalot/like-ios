//
//  LKPostLikeModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"
#import "LKTag.h"

LC_BLOCK(void, LKPostLikeModelRequestFinished, (LKHttpRequestResult * result, NSString * error));

@interface LKTagLikeModel : LCHTTPRequestModel

+(void) likeOrUnLike:(LKTag *)tag requestFinished:(LKPostLikeModelRequestFinished)requestFinished;

@end
