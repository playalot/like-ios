//
//  LKUserFavouritesInterface.h
//  LIKE
//
//  Created by huangweifeng on 9/23/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKUserFavouritesInterface : LKBaseInterface

LC_PROPERTY(assign) NSNumber *timestamp;

- (instancetype)initWithTimeStamp:(NSNumber *)timestamp;

- (NSArray *)posts;

- (NSNumber *)next;

@end
