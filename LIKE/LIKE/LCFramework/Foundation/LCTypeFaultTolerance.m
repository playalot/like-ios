//
//  LCTypeFaultTolerance.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCTypeFaultTolerance.h"

@implementation NSObject (LCTypeFaultTolerance)

- (NSString *) isNSString
{
    if ([self isKindOfClass:[NSString class]]){
        
        return (NSString *)self;
    }
    else if ([self isKindOfClass:[NSData class]]){
        
        NSData * data = (NSData *)self;
        
        return [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    }
    else if ([self isKindOfClass:[NSNumber class]]){
        
        return LC_NSSTRING_FORMAT(@"%@",self);
    }
    else if ([self isKindOfClass:[NSNull class]]){
        
        return @"";
    }
    else{
        
        return [NSString stringWithFormat:@"%@", self];
    }
}

@end
