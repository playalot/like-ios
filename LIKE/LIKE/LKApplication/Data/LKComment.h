//
//  LKComment.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/27.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCDataModel.h"
#import "LKUser.h"

@interface LKComment : LCDataModel

LC_PROPERTY(strong) NSNumber * id;
LC_PROPERTY(strong) LKUser * user;
LC_PROPERTY(strong) LKUser * replyUser;
LC_PROPERTY(strong) NSString * content;
LC_PROPERTY(strong) NSNumber * timestamp;
LC_PROPERTY(strong) NSString * location;

@end
