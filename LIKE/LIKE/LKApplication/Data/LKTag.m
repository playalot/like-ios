//
//  LKTag.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTag.h"

@implementation LKTag

-(instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (self = [super init]) {
        
        self.id = dict[@"mark_id"];
        self.tag = dict[@"tag"];
        self.likes = dict[@"likes"];
        self.group = dict[@"group"];
        self.isLiked = [dict[@"is_liked"] boolValue];
        self.createTime = dict[@"created"];
        self.user = [LKUser objectFromDictionary:dict[@"user"]];
        self.image = dict[@"image"];

        self.comments = [NSMutableArray array];
        
        NSArray * comments = dict[@"comments"];
        
        if (comments && [comments isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary * tmp in comments) {
                
                [self.comments addObject:[LKComment objectFromDictionary:tmp]];
            }
        }
        
        self.totalComments = dict[@"total_comments"];
        
        
        self.likers = [NSMutableArray array];
        
        NSArray * likers = dict[@"likers"];

        if (likers && [likers isKindOfClass:[NSArray class]]) {

            for (NSDictionary * tmp in likers) {
                
                [self.likers addObject:[LKUser objectFromDictionary:tmp]];
            }
        }

    }
    
    return self;
}

@end
