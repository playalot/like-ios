//
//  LKWeChatShare.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

LC_BLOCK(void, LKWeChatLoginComplete, (NSString * uid, NSString * accessToken, NSString * error));

@interface LKWeChatShare : NSObject <WXApiDelegate>

+(BOOL) shareImage:(UIImage *)image timeLine:(BOOL)timeLine;

-(void)login:(LKWeChatLoginComplete)complete;

@end
