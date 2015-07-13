//
//  LKPost.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPost.h"
#import "LKComment.h"

@implementation LKPost

-(instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (self = [super init]) {
        
        self.id = dict[@"post_id"];
        self.type = [dict[@"type"] integerValue];
        self.content = dict[@"content"];
        self.timestamp = dict[@"created"];
        self.user = [LKUser objectFromDictionary:dict[@"user"]];
        self.place = [dict[@"place"] isKindOfClass:[NSString class]] && [dict[@"place"] length] ? dict[@"place"] : nil;
        self.tags = [NSMutableArray array];
        
        NSArray * tags = dict[@"marks"];
        
        if (tags) {
            
            for (NSDictionary * tmp in tags) {
                
                [self.tags addObject:[LKTag objectFromDictionary:tmp]];
            }
        }
        
    }
    
    return self;
}

@end
