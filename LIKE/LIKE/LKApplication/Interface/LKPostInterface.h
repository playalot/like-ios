//
//  LKPostInterface.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/10.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKPostInterface : LKBaseInterface

LC_PROPERTY(copy)NSNumber *postId;

- (instancetype)initWithPostId:(NSNumber *)postId;

- (NSString *)preview;

@end
