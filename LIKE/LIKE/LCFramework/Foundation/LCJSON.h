//
//  LCJSON.h
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-7.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCJSON : NSObject

+(id) objecFromJSONObject:(id)object;

@end

@interface NSString (LCJSON)

-(id) objectFromJSONString;

@end

@interface NSData (LCJSON)

-(id) objectFromJSONData;

@end

@interface NSArray (LCJSON)

-(NSString *) JSONString;
-(NSData *) JSONData;

@end

@interface NSDictionary (LCJSON)

-(NSString *) JSONString;
-(NSData *) JSONData;

@end