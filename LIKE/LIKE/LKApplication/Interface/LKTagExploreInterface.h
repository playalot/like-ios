//
//  LKTagExploreInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKTagExploreInterface : LKBaseInterface

LC_PROPERTY(copy) NSString *tagValue;
LC_PROPERTY(copy) NSNumber *timestamp;

- (NSArray *)users;
- (NSArray *)posts;

@end