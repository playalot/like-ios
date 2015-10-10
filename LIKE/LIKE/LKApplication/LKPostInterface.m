//
//  LKPostInterface.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/10.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostInterface.h"

@implementation LKPostInterface

- (instancetype)initWithPostId:(NSNumber *)postId {
    
    if (self = [super init]) {
        self.postId = postId;
    }
    return self;
}

- (NSString *)requestUrl {
    if (self.postId) {
        return [NSString stringWithFormat:@"/v1/post/%@", self.postId];
    }
    return nil;
}

- (NSString *)preview {
    return self.responseJSONObject[@"data"][@"preview"];
}

@end
