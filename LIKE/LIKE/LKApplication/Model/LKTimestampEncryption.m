//
//  LKTimestampEncryption.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTimestampEncryption.h"
#import <CommonCrypto/CommonDigest.h>

@implementation LKTimestampEncryption

+(NSString *) encryption:(NSInteger)timestamp
{
    timestamp /= 60;
    
    NSString * timestampString = [NSString stringWithFormat:@"%@", @(timestamp)];
    
    NSMutableDictionary * keys = [NSMutableDictionary dictionary];
    [keys setObject:@"x" forKey:@"0"];
    [keys setObject:@"v" forKey:@"1"];
    [keys setObject:@"." forKey:@"2"];
    [keys setObject:@"e" forKey:@"3"];
    [keys setObject:@"5" forKey:@"4"];
    [keys setObject:@"0" forKey:@"5"];
    [keys setObject:@";" forKey:@"6"];
    [keys setObject:@"r" forKey:@"7"];
    [keys setObject:@"8" forKey:@"8"];
    [keys setObject:@"@" forKey:@"9"];

    NSMutableArray * numberArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 8; i++) {
        
        NSString * word = [timestampString substringWithRange:NSMakeRange(i, 1)];
        
        [numberArray addObject:word];
    }
    
    NSMutableString * resultString = [NSMutableString string];
    
    // 47015263
    [resultString appendString:keys[numberArray[4]]];
    [resultString appendString:keys[numberArray[7]]];
    [resultString appendString:keys[numberArray[0]]];
    [resultString appendString:keys[numberArray[1]]];
    [resultString appendString:keys[numberArray[5]]];
    [resultString appendString:keys[numberArray[2]]];
    [resultString appendString:keys[numberArray[6]]];
    [resultString appendString:keys[numberArray[3]]];

    return [[LKTimestampEncryption MD532:resultString] uppercaseString];
}

+ (NSString *)MD532:(NSString *)str
{
    const char * cStr = [str UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end
