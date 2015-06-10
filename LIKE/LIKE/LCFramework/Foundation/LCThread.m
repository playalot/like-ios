//  LC_Thread.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCThread.h"

#define OPERATION_COUNT 5

@implementation LCThreadQueue

-(instancetype) init
{
    LC_SUPER_INIT({
      
        self.maxConcurrentOperationCount = OPERATION_COUNT;
        
    })
}

+(BOOL) cancelWithTagString:(NSString *)tagString
{
    LCThread * thread = [LCThreadQueue threadWithTagString:tagString];
    
    if (thread) {
        [thread cancel];
        return YES;
    }
    
    return NO;
}

+(LCThread *) threadWithTagString:(NSString *)tagString
{
    NSArray * operations = LCThreadQueue.singleton.operations;
    
    for (LCThread * thread in operations) {
        
        if (!LC_NSSTRING_IS_INVALID(thread.tagString)) {
            
            if ([thread.tagString isEqualToString:tagString]) {
                return thread;
            }
        }
    }
    
    return nil;
}

@end

@implementation LCThread

+(LCThread *) performOperationBlockInBackground:(LCOperationBlock)block completeBlock:(LCOperationCompleteBlock)completeBlock
{
    LCThread * thread = [[LCThread alloc] initWithOperationBlock:block completeBlock:completeBlock];
    
    [LCThreadQueue.singleton addOperation:thread];

    return thread;
}

-(instancetype) initWithOperationBlock:(LCOperationBlock)block completeBlock:(LCOperationCompleteBlock)completeBlock
{
    LC_SUPER_INIT({
        
        self.operationBlock = block;
        self.operationCompleteBlock = completeBlock;
        self.object = nil;
        self.tagString = nil;
    })
}

-(void) main
{
    if (self.operationBlock) {
        self.operationBlock();
    }else{
        ERROR(@"[LCThread] not found 'operationBlock'.");
    }
    
    if (self.operationCompleteBlock) {
        
        [LCGCD dispatchAsyncInMainQueue:^{
           
            self.operationCompleteBlock();
            
        }];
    }
}

@end
