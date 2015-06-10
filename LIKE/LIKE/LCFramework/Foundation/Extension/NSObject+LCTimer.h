//
//  NSObject+LCTimer.h
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-3.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (LCTimer)

@property (nonatomic,retain) NSString * timerName;

-(BOOL) is:(NSString *)name;

@end


@interface NSObject (LCTimer)

#define LC_HANDLE_TIMER(timer) -(void) handleTimer:(NSTimer *)timer

-(void) handleTimer:(NSTimer *)timer;

-(NSTimer *) fireTimer:(NSString *)name timeInterval:(NSTimeInterval)timeInterval repeat:(BOOL)repeat;

-(void) cancelTimer:(NSString *)name;
-(void) cancelAllTimers;

@end
