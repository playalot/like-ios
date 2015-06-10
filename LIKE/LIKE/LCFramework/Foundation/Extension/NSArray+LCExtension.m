//
//  NSArray+LCExtension.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "NSArray+LCExtension.h"

@implementation NSArray (LCExtension)

@end


@implementation NSMutableArray (LCExtension)

static const void *	__TTRetainNoOp( CFAllocatorRef allocator, const void * value ) { return value; }
static void			__TTReleaseNoOp( CFAllocatorRef allocator, const void * value ) { }

+ (NSMutableArray *)nonRetainingArray
{
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.retain = __TTRetainNoOp;
    callbacks.release = __TTReleaseNoOp;
    return CFBridgingRelease(CFArrayCreateMutable( nil, 0, &callbacks ));
}

@end