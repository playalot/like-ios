//
//  LC_SQLite.m
//  LCFramework
//
//  Created by CBSi-Leer on 14-3-12.
//  Copyright (c) 2014年 Licheng Guo iOS Developer ( http://nsobject.me ). All rights reserved.
//

#import "LCSQLite.h"

@interface LCSQLite ()

@end

@implementation LCSQLite


-(LCThreadQueue *) queue
{
    if (!_queue) {
        
        self.queue = [[LCThreadQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    
    return _queue;
}


- (void) executeUpdate:(NSString*)sql completeBlock:(LCSQLiteUpdateCompleteBlock)block
{
    __block BOOL complete = NO;
    
    if (self.asynchronousPerform) {
     
        @weakly(self);
        
        LCThread * thread = [[LCThread alloc] initWithOperationBlock:^{
            
            @normally(self);
            
            complete = [self executeUpdate:sql];
            
        } completeBlock:^{
            
            block(complete);
            
        }];
        
        [self.queue addOperation:LC_AUTORELEASE(thread)];
        
    }
    else{
     
        complete = [self executeUpdate:sql];
        block(complete);
        
    }
}


- (void) executeQuery:(NSString*)sql completeBlock:(LCSQLiteQueryCompleteBlock)block
{
    __block FMResultSet * result = nil;
    
    if (self.asynchronousPerform) {

        @weakly(self);
        
        LCThread * thread = [[LCThread alloc] initWithOperationBlock:^{
            
            @normally(self);
            
            result = [self executeQuery:sql];
            
        } completeBlock:^{
            
            block(result);
            
        }];
        
        [self.queue addOperation:LC_AUTORELEASE(thread)];
        
    }
    else{
        
        result = [self executeQuery:sql];
        block(result);
    }
}


@end
