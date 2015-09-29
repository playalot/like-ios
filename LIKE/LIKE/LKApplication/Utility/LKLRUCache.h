//
//  LKLRUCache.h
//  LKLRUCache
//
//  Created by Jason Kaer on 15/7/11.
//  Copyright (c) 2015年 Jason Kaer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKLRUCache : NSObject

/**
 *  Capacity of cache.(Total Count of objects to be cached.)
 */
@property (nonatomic, readonly, assign) NSUInteger capacity;

/**
 *  The current count of objects in cache.
 */
@property (nonatomic, readonly, assign) NSUInteger length;


- (instancetype)initWithCapacity:(NSUInteger)capacity  NS_DESIGNATED_INITIALIZER ;

- (id)objectForKey:(NSString *)key;

- (void)setObject:(id)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)show;

@end
