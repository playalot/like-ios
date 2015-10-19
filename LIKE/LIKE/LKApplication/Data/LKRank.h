//
//  LKRank.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/19.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCDataModel.h"

@interface LKRank : LCDataModel

LC_PROPERTY(strong) NSNumber *likes;
LC_PROPERTY(strong) NSNumber *rank;
LC_PROPERTY(strong) NSNumber *up;
LC_PROPERTY(copy) NSString *userId;

@end
