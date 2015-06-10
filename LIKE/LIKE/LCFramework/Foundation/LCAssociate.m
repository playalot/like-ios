//
//  LCAssociat.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCAssociate.h"
#import <objc/runtime.h>

@implementation LCAssociate

+(id) getAssociatedObject:(id)object key:(const void *)key
{
    return objc_getAssociatedObject(object, key);
}

+(void) setAssociatedObject:(id)object value:(id)value key:(const void *)key
{
    objc_setAssociatedObject(object, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
