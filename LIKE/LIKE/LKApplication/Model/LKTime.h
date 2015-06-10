//
//  LKTime.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKTime : NSObject

+ (NSString *) dateNearByTimestamp:(NSNumber *)timestamp;
+ (NSString *) dateStringByTimestamp:(NSNumber *)timeStamp;
+ (NSString *) dateStringByTimestamp:(NSNumber *)timeStamp format:(NSString *)format;

@end
