//
//  LC_Binder.m
//  NextApp
//
//  Created by Licheng Guo . http://nsobject.me/ on 14/11/5.
//  Copyright (c) 2014年 http://nextapp.com.cn/. All rights reserved.
//

#import "LCValueBinder.h"
#import "LCObserver.h"

@interface LCValueBinder ()

LC_PROPERTY(strong) LCObserver * observer;

@end

@implementation LCValueBinder

-(void) dealloc
{
    [self stopBinding];
}

- (id)initForBindingFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
                      toObject:(id)toObject keyPath:(NSString *)toKeyPath
           transformationBlock:(LCBinderTransformationBlock)transformationBlock
{
    if((self = [super init])) {
        
        __weak id wToObject = toObject;
        
        NSString * myToKeyPath = [toKeyPath copy];
        
        LCObserverBlockWithChangeDictionary changeBlock;
        
        if(transformationBlock) {
            
            changeBlock = [^(NSDictionary *change) {
                [wToObject setValue:transformationBlock(change[NSKeyValueChangeNewKey])
                         forKeyPath:myToKeyPath];
            } copy];
            
        } else {
            
            changeBlock = [^(NSDictionary *change) {
                [wToObject setValue:change[NSKeyValueChangeNewKey]
                         forKeyPath:myToKeyPath];
            } copy];
        }
        
        _observer = [LCObserver observerForObject:fromObject
                                          keyPath:fromKeyPath
                                          options:NSKeyValueObservingOptionNew
                                      changeBlock:changeBlock];
    }
    return self;
}

- (void)stopBinding
{
    [_observer stopObserving];
    self.observer = nil;
}

+ (id)binderFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
              toObject:(id)toObject keyPath:(NSString *)toKeyPath
{
    return [[self alloc] initForBindingFromObject:fromObject keyPath:fromKeyPath
                                         toObject:toObject keyPath:toKeyPath
                              transformationBlock:nil];
}

+ (id)binderFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
              toObject:(id)toObject keyPath:(NSString *)toKeyPath
      valueTransformer:(NSValueTransformer *)valueTransformer
{
    return [[self alloc] initForBindingFromObject:fromObject keyPath:fromKeyPath
                                         toObject:toObject keyPath:toKeyPath
                              transformationBlock:^id(id value) {
                                  return [valueTransformer transformedValue:value];
                              }];
}

+ (id)binderFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath
              toObject:(id)toObject keyPath:(NSString *)toKeyPath
   transformationBlock:(LCBinderTransformationBlock)transformationBlock
{
    return [[self alloc] initForBindingFromObject:fromObject keyPath:fromKeyPath
                                         toObject:toObject keyPath:toKeyPath
                              transformationBlock:transformationBlock];
}

+ (id)binderFromObject:(id)fromObject keyPath:(NSString *)fromKeyPath toObject:(id)toObject keyPath:(NSString *)toKeyPath formatter:(NSFormatter *)formatter;
{
    return [[self alloc] initForBindingFromObject:fromObject keyPath:fromKeyPath
                                         toObject:toObject keyPath:toKeyPath
                              transformationBlock:^id(id value) {
                                  return [formatter stringForObjectValue: value];
                              }];
}


@end
