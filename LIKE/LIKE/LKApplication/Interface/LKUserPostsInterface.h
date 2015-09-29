//
//  LKUserPostsInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/23/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKUserPostsInterface : LKBaseInterface

LC_PROPERTY(strong) NSNumber *timestamp;

- (instancetype)initWithTimeStamp:(NSNumber *)timestamp uid:(NSNumber *)uid;

LC_PROPERTY(strong) NSNumber *uid;

- (NSArray *)posts;

- (NSNumber *)next;

@end
