//
//  LKUserDefaults.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/23.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserDefaults.h"

@implementation LKUserDefaults

-(instancetype) init
{
    if (self = [super initWithPath:[[LCSanbox documentPath] stringByAppendingString:@"/LKUserDefaults.db"]]) {
        
    }
    
    return self;
}

@end
