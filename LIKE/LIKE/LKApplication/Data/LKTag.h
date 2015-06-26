//
//  LKTag.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCDataModel.h"
#import "LKComment.h"

@interface LKTag : LCDataModel

LC_PROPERTY(strong) NSNumber * id;
LC_PROPERTY(strong) NSString * tag;
LC_PROPERTY(strong) NSNumber * likes;
LC_PROPERTY(assign) BOOL isLiked;
LC_PROPERTY(strong) NSNumber * createTime;
LC_PROPERTY(strong) LKUser * user;
LC_PROPERTY(strong) NSMutableArray * comments;
LC_PROPERTY(strong) NSNumber * totalComments;
LC_PROPERTY(copy) NSString * image;

@end
