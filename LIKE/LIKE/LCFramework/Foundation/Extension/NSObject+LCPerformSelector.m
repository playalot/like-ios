//
//  NSObject+LCPerformSelector.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "NSObject+LCPerformSelector.h"

@implementation NSObject (LCPerformSelector)

-(LCPerformSelector) PERFORM
{
    LCPerformSelector block = ^ id (SEL selector, __strong id object){
        
        if ([self respondsToSelector:selector]) {
            
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
            return [self performSelector:selector withObject:object];
            _Pragma("clang diagnostic pop") \
        }
        
        return nil;
    };
    
    return [block copy];
}

-(LCPerformSelectorDelay) PERFORM_DELAY
{
    LCPerformSelectorDelay block = ^ void (SEL selector, id object, NSTimeInterval delay){
        
        if ([self respondsToSelector:selector]) {
            
            [self performSelector:selector withObject:object afterDelay:delay];
        }
    };
    
    return block;
}

@end
