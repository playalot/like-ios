//
//  LCMemoryCache.h
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCMemoryCache : NSObject

LC_PROPERTY(assign) BOOL clearWhenMemoryLow;
LC_PROPERTY(assign) NSUInteger maxCacheCount;
LC_PROPERTY(assign) NSUInteger cachedCount;
LC_PROPERTY(strong) NSMutableArray * cacheKeys;
LC_PROPERTY(strong) NSMutableDictionary * cacheObjs;

- (BOOL)hasObjectForKey:(id)key;

- (id)objectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;

- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;

@end
