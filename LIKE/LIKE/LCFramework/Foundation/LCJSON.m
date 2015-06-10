//
//  LCJSON.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCJSON.h"

@implementation LCJSON

+(id) objecFromJSONObject:(id)object
{
    NSError * error = nil;
    
    NSData * data = nil;
    
    if ([object isKindOfClass:[NSString class]]) {
        
        data = [object dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([object isKindOfClass:[NSData class]]){
    
        data = object;
    }
    else{
        
        ERROR(@"[LCJSON] %@ can't convert to NSData.", object);
        return nil;
    }
    
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];

    
    if (error) {
        
        ERROR(@"[LCJSON] %@",error);
    }
    
    return result;
}

+(NSString *) JSONStringWithOjbect:(id)object
{
    if ([NSJSONSerialization isValidJSONObject:object]) {
        
        NSError * error;
        
        NSData * registerData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString * jsonString = [[NSString alloc] initWithData:registerData encoding:NSUTF8StringEncoding];
        
        return jsonString;
    }
    else{
        
        ERROR(@"[LCJSON] %@ is not a valid value.", self);
    }
    
    return nil;
}

+(NSData *) JSONDataWithOjbect:(id)object
{
    if ([NSJSONSerialization isValidJSONObject:object]) {
        
        NSError * error;
        
        NSData * registerData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        
        return registerData;
    }
    else{
        
        ERROR(@"[LCJSON] %@ is not a valid value.", self);
    }
    
    return nil;
}

@end

@implementation NSString (LCJSON)

-(id) objectFromJSONString
{
    return [LCJSON objecFromJSONObject:self];
}

@end

@implementation NSData (LCJSON)

-(id) objectFromJSONData
{
    return [LCJSON objecFromJSONObject:self];
}

@end

@implementation NSArray (LCJSON)

-(NSString *) JSONString
{
    return [LCJSON JSONStringWithOjbect:self];
}

-(NSData *) JSONData
{
    return [LCJSON JSONDataWithOjbect:self];
}

@end

@implementation NSDictionary (LCJSON)

-(NSString *) JSONString
{
    return [LCJSON JSONStringWithOjbect:self];
}

-(NSData *) JSONData
{
    return [LCJSON JSONDataWithOjbect:self];
}

@end
