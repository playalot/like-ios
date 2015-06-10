//
//  LKUser.h
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCDataModel.h"

@interface LKUser : LCDataModel

LC_PROPERTY(strong) NSNumber * id;
LC_PROPERTY(strong) NSString * name;
LC_PROPERTY(strong) NSString * avatar;
LC_PROPERTY(strong) NSString * originAvatar;
LC_PROPERTY(strong) NSString * cover;

LC_PROPERTY(strong) NSNumber * likes;
LC_PROPERTY(strong) NSNumber * isFollowing;
LC_PROPERTY(strong) NSNumber * postCount;
LC_PROPERTY(strong) NSNumber * followCount;
LC_PROPERTY(strong) NSNumber * fansCount;

@end
