//
//  LKChooseTag.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/9/8.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCDataModel.h"

@interface LKChooseTag : LCDataModel

LC_PROPERTY(strong) NSNumber *count;
LC_PROPERTY(strong) NSNumber *group;
LC_PROPERTY(strong) NSNumber *id;
LC_PROPERTY(copy) NSString *image;
LC_PROPERTY(copy) NSString *tag;

@end
