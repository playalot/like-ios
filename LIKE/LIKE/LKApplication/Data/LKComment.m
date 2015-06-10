//
//  LKComment.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/27.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKComment.h"

@implementation LKComment

-(instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (self = [super init]) {
        
        self.id = dict[@"comment_id"];
        self.user = [LKUser objectFromDictionary:dict[@"user"]];
        
        if (dict[@"reply"] && [dict[@"reply"] isKindOfClass:[NSDictionary class]]) {
            self.replyUser = [LKUser objectFromDictionary:dict[@"reply"]];
        }
        
        self.content = dict[@"content"];
        self.timestamp = dict[@"created"];
        self.location = dict[@"location"];
    }
    
    return self;
}

@end
