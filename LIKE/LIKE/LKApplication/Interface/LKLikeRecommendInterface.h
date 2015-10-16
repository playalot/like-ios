//
//  LKLikeRecommendInterface.h
//  LIKE
//
//  Created by huangweifeng on 10/16/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKLikeRecommendInterface : LKBaseInterface

LC_PROPERTY(copy)NSNumber *timestamp;

- (NSArray *)posts;
- (NSNumber *)next;
- (NSDictionary *)info;

@end
