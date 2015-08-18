//
//  NSObject+LCNotification.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-3.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "NSObject+LCNotification.h"

#define NSNotificationDefaultCenter [NSNotificationCenter defaultCenter]

@implementation NSNotification(LCNotification)

- (BOOL)is:(NSString *)name
{
    return [self.name isEqualToString:name];
}

@end

@implementation NSObject (LCNotification)

- (void)handleNotification:(NSNotification *)notification
{
    
}

- (void)observeNotification:(NSString *)notificationName
{
    INFO(@"[LCNotification] name : %@ observer : %@",notificationName,[self class]);
    
    [NSNotificationDefaultCenter addObserver:self selector:@selector(handleNotification:) name:notificationName object:nil];
}

- (void)unobserveNotification:(NSString *)name
{
    [NSNotificationDefaultCenter removeObserver:self name:name object:nil];
}

- (void)observeNotification:(NSString *)notificationName object:(id)object
{
    INFO(@"[LCNotification] name : %@ observer : %@",notificationName,[self class]);
    
    [NSNotificationDefaultCenter addObserver:self selector:@selector(handleNotification:) name:notificationName object:object];
}

/**
 *  取消所有的通知监听
 */
- (void)unobserveAllNotifications
{
    [NSNotificationDefaultCenter removeObserver:self];
}

+ (BOOL)postNotification:(NSString *)name
{
    INFO(@"[LCNotification] post : %@ sponsor : %@",name,[self class]);
    
    [NSNotificationDefaultCenter postNotificationName:name object:nil];
    
    return YES;
}

+ (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object
{
    INFO(@"[LCNotification] post : %@ sponsor : %@",name,[self class]);
    
    [NSNotificationDefaultCenter postNotificationName:name object:object];
    
    return YES;
}

- (BOOL) postNotification:(NSString *)name
{
    return [[self class] postNotification:name withObject:self];
}

- (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object
{
    return [[self class] postNotification:name withObject:object];
}


@end
