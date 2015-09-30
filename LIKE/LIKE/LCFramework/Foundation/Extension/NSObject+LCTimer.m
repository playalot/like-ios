//
//  NSObject+LCTimer.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-3.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "NSObject+LCTimer.h"

#define TIMER_NAME_KEY "LCTimer.Name.Key"
#define TIMER_SAVE_KEY "LCTimer.Save.Key"

static NSMutableDictionary * __allTimers;

@implementation NSTimer (LCTimer)

-(BOOL) is:(NSString *)timerName
{
    if ([self.timerName isEqualToString:timerName]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)timerName
{
    return [LCAssociate getAssociatedObject:self key:TIMER_NAME_KEY];
}

- (void)setTimerName:(NSString *)timerName
{
    [LCAssociate setAssociatedObject:self value:timerName key:TIMER_NAME_KEY];
}

@end



@implementation NSObject (LCTimer)

- (NSMutableDictionary *) timers
{
    NSMutableDictionary * dic = [LCAssociate getAssociatedObject:self key:TIMER_SAVE_KEY];
    
    if (!dic) {
        
        dic = [NSMutableDictionary dictionary];
        
        [self setTimers:dic];
    }
    
    return dic;
}

- (void)setTimers:(NSMutableDictionary *)timers
{
    [LCAssociate setAssociatedObject:self value:timers key:TIMER_SAVE_KEY];
}

-(NSTimer *) fireTimer:(NSString *)name timeInterval:(NSTimeInterval)timeInterval repeat:(BOOL)repeat {
    if ([self.timers objectForKey:name]){
        return [self.timers objectForKey:name];
    }
    
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(handleTimer:) userInfo:nil repeats:repeat];
    timer.timerName = name;
    [self.timers setObject:timer forKey:name];
    
    INFO(@"[LCTimer] init in %@, name is %@.",[self class], name);
    
    return timer;
}

- (void)cancelTimer:(NSString *)name
{
    NSTimer * timer = [self.timers objectForKey:name];
    
    if (timer) {
        
        [timer invalidate];
        [self.timers removeObjectForKey:name];
        
        // Remove info from static dic.
        INFO(@"[LCTimer] remove in %@, name is %@.",[self class],name);
    }
}

- (void)cancelAllTimers
{
    for (NSString * key in self.timers.allKeys) {
        
        NSTimer * timer = [self.timers objectForKey:key];
        [timer invalidate];
        
        [self.timers removeObjectForKey:key];
        
        INFO(@"[LCTimer] remove in %@, name is %@.",[self class],key);
    }
}

-(void) handleTimer:(NSTimer *)timer
{
    
}

@end
