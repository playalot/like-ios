//
//  LKNotification.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotification.h"

@implementation LKNotification

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (self = [super init]) {
        
        NSString *type = dict[@"type"];
        
        if ([type isEqualToString:@"MARK"]) {
            
            self.type = LKNotificationTypeNewTag;
        }
        else if ([type isEqualToString:@"LIKE"]){
            
            self.type = LKNotificationTypeLikeTag;
        }
        else if ([type isEqualToString:@"FOLLOW"]){
            
            self.type = LKNotificationTypeFocus;
        }
        else if ([type isEqualToString:@"REPLY"]){
            
            self.type = LKNotificationTypeReply;
        }
        else if ([type isEqualToString:@"COMMENT"]){
            
            self.type = LKNotificationTypeComment;
        }
        
        self.user = [LKUser objectFromDictionary:dict[@"user"]];
        
        self.timestamp = dict[@"timestamp"];
        
        self.posts = [NSMutableArray array];
        
        NSArray *tmp = dict[@"posts"];
        
        for (NSDictionary *post in tmp) {
            
            [self.posts addObject:[LKPost objectFromDictionary:post]];
        }
        
        self.post = dict[@"post"] ? [LKPost objectFromDictionary:dict[@"post"]] : nil;
        
        self.tag = dict[@"tag"];
        self.tagID = dict[@"mark_id"];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict nextDict:(NSDictionary *)nextDict error:(NSError *__autoreleasing *)err {
    
    if (self = [super init]) {
        
        NSString *type = dict[@"type"];
        
        if ([type isEqualToString:@"MARK"]) {
            
            self.type = LKNotificationTypeNewTag;
        }
        else if ([type isEqualToString:@"LIKE"]){
            
            self.type = LKNotificationTypeLikeTag;
        }
        else if ([type isEqualToString:@"FOLLOW"]){
            
            self.type = LKNotificationTypeFocus;
        }
        else if ([type isEqualToString:@"REPLY"]){
            
            self.type = LKNotificationTypeReply;
        }
        else if ([type isEqualToString:@"COMMENT"]){
            
            self.type = LKNotificationTypeComment;
        }
        
        self.user = [LKUser objectFromDictionary:dict[@"user"]];
        
        self.timestamp = dict[@"timestamp"];
        
        self.posts = [NSMutableArray array];
        self.tags = [NSMutableArray array];
        
        NSArray *tmp = dict[@"posts"];
        
        for (NSDictionary *post in tmp) {
            
            [self.posts addObject:[LKPost objectFromDictionary:post]];
        }
        
        self.post = dict[@"post"] ? [LKPost objectFromDictionary:dict[@"post"]] : nil;
        
        self.tag = dict[@"tag"];
        self.tagID = dict[@"mark_id"];
        
        NSInteger userId = [dict[@"user"][@"user_id"] integerValue];
        NSInteger nextUserId = [nextDict[@"user"][@"user_id"] integerValue];
        NSInteger postId = [dict[@"post"][@"post_id"] integerValue];
        NSInteger nextPostId = [nextDict[@"post"][@"post_id"] integerValue];
        
        if (userId == nextUserId && postId == nextPostId && [dict[@"type"] isEqualToString:nextDict[@"type"]]) {
            
            [self.tags addObject:dict[@"tag"]];
            [self.tags addObject:nextDict[@"tag"]];
        }
    }
    
    return self;
}

@end
