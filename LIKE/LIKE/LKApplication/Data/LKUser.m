//
//  LKUser.m
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUser.h"

@implementation LKUser

-(instancetype) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err
{
    if (self = [super init]) {
        
        if (dict == nil || [dict isKindOfClass:[NSDictionary class]]) {
    
            self.id = dict[@"user_id"];
            self.name = dict[@"nickname"];
            self.avatar = dict[@"avatar"];
            self.cover = dict[@"cover"];
            self.likes = dict[@"likes"];
            self.isFollowing = dict[@"is_following"];
            self.postCount = dict[@"count"][@"post"];
            self.followCount = dict[@"count"][@"follow"];
            self.fansCount = dict[@"count"][@"fan"];
            self.originAvatar = dict[@"origin_avatar"];

        }
        else{
            
            ERROR(@"...");
        }
    }
    
    return self;
}

@end