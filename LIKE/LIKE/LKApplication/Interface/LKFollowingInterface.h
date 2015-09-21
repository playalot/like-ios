//
//  LKFollowingInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKFollowingInterface : LKBaseInterface

- (instancetype)initWithNext:(NSNumber *)next;

LC_PROPERTY(copy)NSNumber *next;

- (NSNumber *)next;
- (NSArray *)posts;

@end
