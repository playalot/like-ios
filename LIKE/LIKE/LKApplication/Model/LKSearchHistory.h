//
//  LKSearchHistory.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKSearchHistory : NSObject

+(NSArray *)history;

+(void) addHistory:(NSString *)history;

@end
