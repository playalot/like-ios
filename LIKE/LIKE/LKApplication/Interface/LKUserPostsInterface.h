//
//  LKUserPostsInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/23/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKUserPostsInterface : LKBaseInterface

LC_PROPERTY(strong) NSNumber *uid;
LC_PROPERTY(assign) NSInteger page;

- (instancetype)initWithUid:(NSNumber *)uid page:(NSInteger)page;

- (NSArray *)posts;

@end
