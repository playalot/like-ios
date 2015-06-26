//
//  LKTime.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTime.h"
#import "NSDate+TimeAgo.h"

@implementation LKTime

+ (NSString *) dateStringByTimestamp:(NSNumber *)timeStamp format:(NSString *)format
{
    if (timeStamp.integerValue == 0) {
        return @"";
    }
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timeStamp.integerValue];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:format];
    
    NSString * destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;

}

+ (NSString *) dateStringByTimestamp:(NSNumber *)timeStamp
{
    return [LKTime dateStringByTimestamp:timeStamp format:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSString *) dateNearByTimestamp:(NSNumber *)timestamp
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
    
    return [date timeAgo];
    
    /*
    NSString * dateStr = [self dateStringByTimestamp:timestamp];
    
    if (dateStr.length < 19) {
        return LC_LO(@"刚刚");
    }
    
    dateStr = [dateStr substringWithRange:NSMakeRange(0, 19)];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate * convertedDate = [formatter dateFromString:dateStr];
    NSDate * todayDate = [NSDate date];
    
    NSInteger timeInterval = [todayDate timeIntervalSinceDate:convertedDate];//间隔的秒数
    
    NSInteger temp = 0;
    
    NSString * result;
    
    if (timeInterval < 60) {
        
        result = LC_LO(@"刚刚");
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%@%@", @(temp), LC_LO(@"分钟前")];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%@%@", @(temp), LC_LO(@"小时前")];
    }
    
    else if((temp = temp/24) < 30){
        result = [NSString stringWithFormat:@"%@%@", @(temp), LC_LO(@"天前")];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%@%@", @(temp), LC_LO(@"月前")];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%@%@", @(temp), LC_LO(@"年前")];
    }
    
    return  result;
     */
}

@end
