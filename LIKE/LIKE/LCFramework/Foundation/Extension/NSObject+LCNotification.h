//
//  NSObject+LCNotification.h
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-3.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LC_NOTIFICATION_SET(_name) static NSString * const _name = @#_name;

#pragma mark -

@interface NSNotification(LCNotification)

- (BOOL)is:(NSString *)name;

@end

#pragma mark -

@interface NSObject (LCNotification)

#define LC_HANDLE_NOTIFICATION(notification) -(void) handleNotification:(NSNotification *)notification

- (void)handleNotification:(NSNotification *)notification;

- (void)observeNotification:(NSString *)name;
- (void)observeNotification:(NSString *)name object:(id)object;

- (void)unobserveNotification:(NSString *)name;

- (void)unobserveAllNotifications;

+ (BOOL)postNotification:(NSString *)name;
+ (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object;

- (BOOL)postNotification:(NSString *)name;
- (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object;

@end
