//
//  LKUserInfoCache.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUserDefaults.h"

@interface LKUserInfoCache : LCUserDefaults

-(LKUser *) objectForKey:(NSString *)key;
-(LKUser *) objectForKeyedSubscript:(NSString *)key;

@end
