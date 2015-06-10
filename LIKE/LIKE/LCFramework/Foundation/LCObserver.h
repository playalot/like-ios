//
//  LC_Observer.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <Foundation/Foundation.h>

@interface LCObserver : NSObject

LC_BLOCK(void, LCObserverBlock, ());
LC_BLOCK(void, LCObserverBlockWithOldAndNew, (id oldValue, id newValue));
LC_BLOCK(void, LCObserverBlockWithChangeDictionary, (NSDictionary * change));

+ (id)observerForObject:(id)object
                keyPath:(NSString *)keyPath
                  block:(LCObserverBlock)block;

+ (id)observerForObject:(id)object
                keyPath:(NSString *)keyPath
         oldAndNewBlock:(LCObserverBlockWithOldAndNew)block;

+ (id)observerForObject:(id)object
                keyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
            changeBlock:(LCObserverBlockWithChangeDictionary)block;

#pragma mark -

- (void)stopObserving;

@end
