//
//  LKSearchHistory.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchHistory.h"

#define HISTORY_KEY [NSString stringWithFormat:@"LKHistoryKey-%@",LKLocalUser.singleton.user.id]

@implementation LKSearchHistory

+(NSArray *)history
{
    NSArray * array = LKUserDefaults.singleton[HISTORY_KEY];
    
    if (!array) {
        array = [NSArray array];
    }
    
    return array;
}

+(void) addHistory:(NSString *)history
{
    if (history && history.length > 0) {
     
        NSMutableArray * array =  [self.history mutableCopy];
        [array insertObject:history atIndex:0];
        
        if (array.count > 20) {
            [array removeLastObject];
        }
        
        LKUserDefaults.singleton[HISTORY_KEY] = array;
    }
}

@end
