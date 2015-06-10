//
//  LC_Observer.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCObserver.h"

typedef NS_ENUM(NSInteger, LCObserverBlockArgumentsKind)
{
    LCObserverBlockArgumentsNone,
    LCObserverBlockArgumentsOldAndNew,
    LCObserverBlockArgumentsChangeDictionary
};

@interface LCObserver ()
{
    __unsafe_unretained id _observedObject;
}

LC_PROPERTY(copy) NSString * keyPath;
LC_PROPERTY(copy) dispatch_block_t block;

@end


@implementation LCObserver

- (void)dealloc
{
    if(_observedObject) {
        
        [self stopObserving];
    }
}


- (id)initForObject:(id)object
            keyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
              block:(dispatch_block_t)block
 blockArgumentsKind:(LCObserverBlockArgumentsKind)blockArgumentsKind
{
    if(self = [super init])
    {
        if(!object || !keyPath || !block) {
            
            ERROR(@"Observation must have a valid object (%@), keyPath (%@) and block(%@)",object, keyPath, block);
            
        } else {
            
            _observedObject = object;
            self.keyPath = keyPath;
            self.block = block;
            
            [_observedObject addObserver:self
                              forKeyPath:_keyPath
                                 options:options
                                 context:(void *)blockArgumentsKind];
        }
    }
    
    return self;
}

- (void)stopObserving
{
    [_observedObject removeObserver:self forKeyPath:_keyPath];
    
    self.block = nil;
    self.keyPath = nil;
    
    _observedObject = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    switch((LCObserverBlockArgumentsKind)context){
            
        case LCObserverBlockArgumentsNone:
            ((LCObserverBlock)_block)();
            break;
        case LCObserverBlockArgumentsOldAndNew:
            ((LCObserverBlockWithOldAndNew)_block)(change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
            break;
        case LCObserverBlockArgumentsChangeDictionary:
            ((LCObserverBlockWithChangeDictionary)_block)(change);
            break;
        default:
            
            ERROR(@"%s called on %@ with unrecognised context (%p)", __func__, self, context);
    }
}


#pragma mark -


+ (id)observerForObject:(id)object
                keyPath:(NSString *)keyPath
                  block:(LCObserverBlock)block
{
    return [[self alloc] initForObject:object
                               keyPath:keyPath
                               options:0
                                 block:(dispatch_block_t)block
                    blockArgumentsKind:LCObserverBlockArgumentsNone];
}

+ (id)observerForObject:(id)object
                keyPath:(NSString *)keyPath
         oldAndNewBlock:(LCObserverBlockWithOldAndNew)block
{
    return [[self alloc] initForObject:object
                               keyPath:keyPath
                               options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                 block:(dispatch_block_t)block
                    blockArgumentsKind:LCObserverBlockArgumentsOldAndNew];
}

+ (id)observerForObject:(id)object
                keyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
            changeBlock:(LCObserverBlockWithChangeDictionary)block
{
    return [[self alloc] initForObject:object
                               keyPath:keyPath
                               options:options
                                 block:(dispatch_block_t)block
                    blockArgumentsKind:LCObserverBlockArgumentsChangeDictionary];
}


@end
