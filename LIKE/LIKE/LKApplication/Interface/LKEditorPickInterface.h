//
//  LKEditorPickInterface.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/29.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKEditorPickInterface : LKBaseInterface

LC_PROPERTY(copy)NSNumber *timestamp;

- (NSNumber *)next;
- (NSArray *)posts;

@end
