//
//  LCSwizzle.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCSwizzle : NSObject

// 开启容错
+(void) beginFaultTolerant;

+(void) swizzleClass:(Class)aClass originalSelector:(SEL)originalSelector newSelector:(SEL)newSelector;

+(void) swizzleInstance:(Class)aClass originalSelector:(SEL)originalSelector newSelector:(SEL)newSelector;

@end








#pragma mark -

@interface UIView (LCSwizzle)

@end

#pragma mark -

@interface NSArray (LCSwizzle)

@end

#pragma mark -

@interface NSDictionary (LCSwizzle)

@end

#pragma mark -

@interface NSMutableDictionary (LCSwizzle)

@end

#pragma mark -

@interface NSObject (LCSwizzle)

+ (BOOL) swizzleAll;

@end

#pragma mark -