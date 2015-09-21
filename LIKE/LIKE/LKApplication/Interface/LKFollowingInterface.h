//
//  LKFollowingInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKFollowingInterface : LKBaseInterface

LC_PROPERTY(copy)NSNumber *timestamp;

- (NSNumber *)next;
- (NSArray *)posts;
- (NSDictionary *)responseObject;

@end
