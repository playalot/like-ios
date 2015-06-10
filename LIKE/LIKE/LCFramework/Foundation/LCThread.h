//  LC_Thread.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-17.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <Foundation/Foundation.h>

#pragma mark -

@class LCThread;

@interface LCThreadQueue : NSOperationQueue

+(BOOL) cancelWithTagString:(NSString *)tagString;

+(LCThread *) threadWithTagString:(NSString *)tagString;

@end

#pragma mark -

typedef void (^LCOperationBlock) ();
typedef void (^LCOperationCompleteBlock) ();

#pragma mark -

@interface LCThread : NSOperation

@property(nonatomic,copy) LCOperationBlock operationBlock;
@property(nonatomic,copy) LCOperationCompleteBlock operationCompleteBlock;
@property(nonatomic,retain) id object;
@property(nonatomic,retain) NSString * tagString;

+(LCThread *) performOperationBlockInBackground:(LCOperationBlock)block completeBlock:(LCOperationCompleteBlock)completeBlock;

-(LCThread *) initWithOperationBlock:(LCOperationBlock)block completeBlock:(LCOperationCompleteBlock)completeBlock;

@end
