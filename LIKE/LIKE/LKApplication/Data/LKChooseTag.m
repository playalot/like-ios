//
//  LKChooseTag.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/9/8.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKChooseTag.h"

@implementation LKChooseTag

-(instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (self = [super init]) {
        
        if (dict == nil || [dict isKindOfClass:[NSDictionary class]]) {
            
            self.count = dict[@"count"];
            self.group = dict[@"group"];
            self.id = dict[@"id"];
            self.image = dict[@"image"];
            self.tag = dict[@"tag"];
            
        }
        else{
            
            ERROR(@"...");
        }
    }
    
    return self;
}


@end
