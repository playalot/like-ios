//
//  LCMemoryCache.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCMemoryCache.h"

#define DEFAULT_MAX_COUNT (48)

@implementation LCMemoryCache

- (instancetype)init
{
    self = [super init];
    
    if ( self )
    {
        self.clearWhenMemoryLow = YES;
        self.maxCacheCount = DEFAULT_MAX_COUNT;
        self.cachedCount = 0;
        
        self.cacheKeys = [NSMutableArray array];
        self.cacheObjs = [NSMutableDictionary dictionary];
        
        [self observeNotification:UIApplicationDidReceiveMemoryWarningNotification];
    }
    
    return self;
}

- (void)dealloc
{
    [self unobserveAllNotifications];
}

- (BOOL)hasObjectForKey:(id)key
{
    return _cacheObjs[key] ? YES : NO;
}

- (id)objectForKey:(id)key
{
    return _cacheObjs[key];
}

- (void)setObject:(id)object forKey:(id)key
{
    if ( nil == key )
        return;
    
    if ( nil == object )
        return;
    
    _cachedCount += 1;
    
    while (_cachedCount >= _maxCacheCount){
        
        NSString * tempKey = [_cacheKeys objectAtIndex:0];
        
        [_cacheObjs removeObjectForKey:tempKey];
        [_cacheKeys removeObjectAtIndex:0];
        
        _cachedCount -= 1;
    }
    
    [_cacheKeys addObject:key];
    [_cacheObjs setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key
{
    if ([_cacheObjs objectForKey:key]){
        
        [_cacheKeys removeObjectIdenticalTo:key];
        [_cacheObjs removeObjectForKey:key];
        
        _cachedCount -= 1;
    }
}

- (void)removeAllObjects
{
    [_cacheKeys removeAllObjects];
    [_cacheObjs removeAllObjects];
    
    _cachedCount = 0;
}

#pragma mark -

- (void)handleNotification:(NSNotification *)notification
{
    if ([notification is:UIApplicationDidReceiveMemoryWarningNotification]){
        
        if (_clearWhenMemoryLow){
            
            [self removeAllObjects];
        }
    }
}

@end
