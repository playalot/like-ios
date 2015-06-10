//
//  LCModel.m
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCModel.h"

@interface LCModel ()

LC_PROPERTY(strong) NSMutableArray * observers;

@end

@implementation LCModel

- (NSMutableArray *) observers
{
    if (!_observers) {
        
        _observers = [NSMutableArray nonRetainingArray];
    }
    
    return _observers;
}

- (void)addObserver:(id)obj
{
    if ([self.observers containsObject:obj] == NO)
    {
        [self.observers addObject:obj];
    }
}


-(LCModelObserver) OBSERVER
{
    LCModelObserver block = ^ id (id value){
        
        [self addObserver:value];
        return self;
    };
    
    return block;
}


@end
