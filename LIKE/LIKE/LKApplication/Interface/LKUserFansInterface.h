//
//  LKUserFansInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/23/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKUserFansInterface : LKBaseInterface

LC_PROPERTY(copy) NSNumber *uid;
LC_PROPERTY(assign) NSInteger page;

- (instancetype)initWithUid:(NSNumber *)uid page:(NSInteger)page;

- (NSArray *)fans;

@end
