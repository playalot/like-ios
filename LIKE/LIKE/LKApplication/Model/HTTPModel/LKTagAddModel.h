//
//  LKTagAddModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"
#import "LKPost.h"

LC_BLOCK(void, LKTagAddModelRequestFinished, (LKHttpRequestResult * result, NSString * error));

@interface LKTagAddModel : LCHTTPRequestModel

+(void) addTagString:(NSString *)tag onPost:(LKPost *)post requestFinished:(LKTagAddModelRequestFinished)requestFinished;

@end
