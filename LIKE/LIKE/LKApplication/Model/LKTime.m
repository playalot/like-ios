//
//  LKTime.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTime.h"

@implementation LKTime

+ (NSString *) dateStringByTimestamp:(NSNumber *)timeStamp format:(NSString *)format
{
    if (timeStamp.integerValue == 0) {
        return @"";
    }
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timeStamp.integerValue];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
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
        
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%@分钟前", @(temp)];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%@小时前", @(temp)];
    }
    
    else if((temp = temp/24) < 30){
        result = [NSString stringWithFormat:@"%@天前", @(temp)];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%@月前", @(temp)];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%@年前", @(temp)];
    }
    
    return  result;
}

@end
