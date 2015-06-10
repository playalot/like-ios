//
//  LCFileCache.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCFileCache.h"

@implementation LCFileCache

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        self.cachePath = [NSString stringWithFormat:@"%@/LCCache/", [LCSanbox libCachePath]];
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (NSString *)fileNameForKey:(NSString *)key
{
    NSString * pathName = self.cachePath;
    
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:pathName]){
        
        [[NSFileManager defaultManager] createDirectoryAtPath:pathName
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    return [pathName stringByAppendingString:key];
}

- (BOOL)hasObjectForKey:(id)key
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self fileNameForKey:key]];
}

- (id)objectForKey:(id)key
{
    NSData * data = [NSData dataWithContentsOfFile:[self fileNameForKey:key]];
    if ( data )
    {
        return [self unserialize:data];
    }
    
    return nil;
}

- (void)setObject:(id)object forKey:(id)key
{
    if ( nil == object )
    {
        [self removeObjectForKey:key];
    }
    else
    {
        NSData * data = nil;
        
        if ( [object isKindOfClass:[NSData class]] )
        {
            data = (NSData *)object;
        }
        else
        {
            data = [self serialize:object];
        }
        
        [data writeToFile:[self fileNameForKey:key]
                  options:NSDataWritingAtomic
                    error:NULL];
    }
}

- (void)removeObjectForKey:(NSString *)key
{
    [[NSFileManager defaultManager] removeItemAtPath:[self fileNameForKey:key] error:nil];
}

- (void)removeAllObjects
{
    [[NSFileManager defaultManager] removeItemAtPath:_cachePath error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (NSData *)serialize:(id)obj
{
    if ([obj isKindOfClass:[NSData class]])
        return obj;
    
    if ([obj respondsToSelector:@selector(JSONData)])
        return [obj JSONData];
    
    return nil;
}

- (id)unserialize:(NSData *)data
{
    return [LCJSON objecFromJSONObject:data];
}

@end
