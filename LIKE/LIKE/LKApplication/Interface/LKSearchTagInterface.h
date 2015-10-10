//
//  LKSearchTagInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/28/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKSearchTagInterface : LKBaseInterface

LC_PROPERTY(strong) NSString *searchString;
LC_PROPERTY(copy)NSNumber *timestamp;

- (instancetype)initWithSearchString:(NSString *)searchString;

- (NSArray *)posts;
- (NSNumber *)next;

@end
