//
//  LCAssociat.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCAssociate : NSObject

+(id) getAssociatedObject:(id)object key:(const void *)key;
+(void) setAssociatedObject:(id)object value:(id)value key:(const void *)key;

@end
