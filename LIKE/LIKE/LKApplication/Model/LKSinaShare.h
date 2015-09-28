//
//  LKSinaShare.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/19.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"

LC_BLOCK(void, LKSinaLoginComplete, (NSString * uid, NSString * accessToken, NSString * error));

@interface LKSinaShare : NSObject <WeiboSDKDelegate>

+ (BOOL)shareImage:(UIImage *)image;

- (void)login:(LKSinaLoginComplete)complete;

@end
