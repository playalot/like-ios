//
//  IFConfig.m
//  IFAPP
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/3/2.
//  Copyright (c) 2015年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "LKFileUploaderConfig.h"

@implementation LKConfig

-(instancetype) init
{
    if (self = [super initWithPath:[[LCSanbox documentPath] stringByAppendingString:LC_NSSTRING_FORMAT(@"/%@.db",[self class])]]) {
        
    }
    
    return self;
}

@end


@implementation LKQiniuConfig

/** FU == File Uploder */
#define LK_FU_TOKEN @"LKQiniuConfig.Token.Key"
#define LK_FU_SPACE @"LKQiniuConfig.Space.Key"
#define LK_FU_EXPIRES @"LKQiniuConfig.Expires.Key"

-(void) setToken:(NSString *)token
{
    if (!LC_NSSTRING_IS_INVALID(token)) {
        
        self[LK_FU_TOKEN] = token;
    }
}

-(NSString *) token
{
    return self[LK_FU_TOKEN];
}

-(void) setSpace:(NSString *)space
{
    if (LC_NSSTRING_IS_INVALID(space)) {
        
        self[LK_FU_SPACE] = space;
    }
}

-(NSString *) space
{
    return self[LK_FU_SPACE];
}

-(void) setExpires:(NSNumber *)expires
{
    if (expires) {
        
        self[LK_FU_EXPIRES] = expires;
    }
}

-(NSNumber *) expires
{
    return self[LK_FU_EXPIRES];
}

@end
