//
//  LKHotTagDetail.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/7/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKTag.h"

@interface LKHotTagDetail : NSObject

LC_PROPERTY(strong) LKTag * tag;
LC_PROPERTY(strong) NSArray * covers; // <LKPost>
LC_PROPERTY(strong) NSArray * relatedTags; // <LKTag>
LC_PROPERTY(strong) NSArray * content; // <LKPost>

@end
