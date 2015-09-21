//
//  LKTopSearchInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKTopSearchInterface : LKBaseInterface

LC_PROPERTY(strong) NSString *searchString;

- (instancetype)initWithSearchString:(NSString *)searchString;

- (NSArray *)users;

- (NSArray *)tags;

@end
