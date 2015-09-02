//
//  LKPost.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCDataModel.h"
#import "LKUser.h"
#import "LKTag.h"
#import "LKComment.h"

@interface LKPost : LCDataModel

LC_PROPERTY(strong) LKUser * user;

LC_PROPERTY(strong) NSNumber *id;
LC_PROPERTY(assign) NSInteger type;
LC_PROPERTY(strong) NSString *content;
LC_PROPERTY(strong) NSNumber *timestamp;
LC_PROPERTY(strong) NSMutableArray *tags;
LC_PROPERTY(copy)   NSString *place;

LC_PROPERTY(assign) NSInteger reason;
LC_PROPERTY(copy) NSString *reasonTag;

LC_PROPERTY(assign) BOOL favorited;

@end
