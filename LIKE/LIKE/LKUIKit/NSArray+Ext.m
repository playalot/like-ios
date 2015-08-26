//
//  NSArray+Ext.m
//  01-NSURLRequest
//
//  Created by Elkins.Zhao on 15/6/8.
//  Copyright (c) 2015年 elkins. All rights reserved.
//

#import "NSArray+Ext.h"

@implementation NSArray (Ext)

- (NSString *)descriptionWithLocale:(id)locale {
 
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    
    NSRange range;
    range.location = strM.length - 2;
    range.length = 2;
    
    [strM replaceOccurrencesOfString:@",\n" withString:@"\n" options:0 range:range];
    
    [strM appendString:@")\n"];
    
    return [strM copy];
}

@end

@implementation NSDictionary (Ext)

- (NSString *)descriptionWithLocale:(id)locale {
    
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@ = %@,\n", key, obj];
    }];
    
    NSRange range;
    range.location = strM.length - 2;
    range.length = 2;
    
    [strM replaceOccurrencesOfString:@",\n" withString:@"\n" options:0 range:range];
    
    [strM appendString:@"}\n"];
    
    return [strM copy];
}

@end
