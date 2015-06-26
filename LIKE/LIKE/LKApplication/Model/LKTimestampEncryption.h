//
//  LKTimestampEncryption.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKTimestampEncryption : NSObject

+(NSString *) encryption:(NSInteger)timestamp;

@end
