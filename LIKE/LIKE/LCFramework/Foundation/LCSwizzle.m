//
//  LCSwizzle.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCSwizzle.h"
#import <objc/runtime.h>

@implementation UIView (LCSwizzle)

- (void) swizzleAddSubView:(UIView *)view
{
    if (!view) {
        return ;
    }
    
    if (view == self) {
        
        ERROR(@"%@ can't add self.", [self class]);
        return;
    }
    
    if (![view isKindOfClass:[UIView class]]) {
        
        ERROR(@"%@ can't add %@.", [self class],[view class]);
        return;
    }
    
    [self swizzleAddSubView:view];
}

@end

@implementation NSArray (LCSwizzle)

- (id) swizzleObjectAtIndex:(int)index
{
    if(index>=0 && index < self.count)
    {
        return [self swizzleObjectAtIndex:index];
    }
    
    ERROR(@"Invalid index %d at %@",index,self);
    
    return nil;
}

@end

@implementation NSMutableArray (LCSwizzle)

- (void) swizzleRemoveObjectAtIndex:(int)index
{
    if(index >= 0 && index < self.count){
        
        [self swizzleRemoveObjectAtIndex:index];
    }
    else{
        
        ERROR(@"Invalid index %d at %@",index,self);
    }
}

-(void) swizzleInsertObject:(id)object atIndex:(NSInteger)index
{
    if (!object) {
        
        ERROR(@"Object cannot be nil.");
        return;
    }
    
    [self swizzleInsertObject:object atIndex:index];
}

-(void) swizzleAddObject:(id)object
{
    if (!object) {
        
        ERROR(@"Object cannot be nil.");
        return;
    }
    
    [self swizzleAddObject:object];
}


@end


@implementation NSDictionary (LCSwizzle)


@end



@implementation NSMutableDictionary (LCSwizzle)

- (id) swizzleSetObject:(id)object forKey:(id<NSCopying>)key
{
    if(object && key)
    {
        return [self swizzleSetObject:object forKey:key];
    }
    
    ERROR(@"Object或key为空！ %@ %@",object,key);
    
    return nil;
}

-(void) swizzleRemoveObjectForKey:(id<NSCopying>)key
{
    if (key) {
        
        return [self swizzleRemoveObjectForKey:key];
    }
    
    ERROR(@"Key为空！");
}

@end


@implementation LCSwizzle

+(void) beginFaultTolerant
{
    [self swizzleInstance:objc_getClass("__NSArrayI") originalSelector:@selector(objectAtIndex:) newSelector:@selector(swizzleObjectAtIndex:)];
    [self swizzleInstance:objc_getClass("__NSArrayM") originalSelector:@selector(removeObjectAtIndex:) newSelector:@selector(swizzleRemoveObjectAtIndex:)];
    [self swizzleInstance:objc_getClass("__NSArrayM") originalSelector:@selector(insertObject:atIndex:) newSelector:@selector(swizzleInsertObject:atIndex:)];
    [self swizzleInstance:objc_getClass("__NSArrayM") originalSelector:@selector(addObject:) newSelector:@selector(swizzleAddObject:)];
}

+(void) swizzleInstance:(Class)aClass originalSelector:(SEL)originalSelector newSelector:(SEL)newSelector
{
    Method orig_method = nil, alt_method = nil;
    
    // First, look for the methods
    orig_method = class_getInstanceMethod(aClass, originalSelector);
    alt_method = class_getInstanceMethod(aClass, newSelector);
    
    if (class_addMethod(aClass, originalSelector, method_getImplementation(alt_method), method_getTypeEncoding(alt_method))) {
        class_replaceMethod(aClass, newSelector, method_getImplementation(orig_method), method_getTypeEncoding(orig_method));
    }
    else{
        
        // If both are found, swizzle them
        if ((orig_method != nil) && (alt_method != nil)) {
            method_exchangeImplementations(orig_method, alt_method);
        }
    }
}

+(void) swizzleClass:(Class)aClass originalSelector:(SEL)originalSelector newSelector:(SEL)newSelector
{
    Method orig_method = nil, alt_method = nil;
    
    // First, look for the methods
    orig_method = class_getClassMethod(aClass, originalSelector);
    alt_method = class_getClassMethod(aClass, newSelector);
    
    if (class_addMethod(aClass, originalSelector, method_getImplementation(alt_method), method_getTypeEncoding(alt_method))) {
        class_replaceMethod(aClass, newSelector, method_getImplementation(orig_method), method_getTypeEncoding(orig_method));
    }
    else{
        
        // If both are found, swizzle them
        if ((orig_method != nil) && (alt_method != nil)) {
            method_exchangeImplementations(orig_method, alt_method);
        }
    }
}

@end
