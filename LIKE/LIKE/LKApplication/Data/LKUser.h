//
//  LKUser.h
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCDataModel.h"

@interface LKUser : LCDataModel
/**
 *  用户ID
 */
LC_PROPERTY(strong) NSNumber *id;
/**
 *  用户昵称
 */
LC_PROPERTY(strong) NSString *name;
/**
 *  用户头像url
 */
LC_PROPERTY(strong) NSString *avatar;
/**
 *  用户的头像原图
 */
LC_PROPERTY(strong) NSString *originAvatar;
/**
 *  遮罩
 */
LC_PROPERTY(strong) NSString *cover;
/**
 *  用户获取的like数量
 */
LC_PROPERTY(strong) NSNumber *likes;
/**
 *  是否follow
 */
LC_PROPERTY(strong) NSNumber *isFollowing;
/**
 *  发布作品数量
 */
LC_PROPERTY(strong) NSNumber *postCount;
/**
 *  关注数量
 */
LC_PROPERTY(strong) NSNumber *followCount;
/**
 *  粉丝数量
 */
LC_PROPERTY(strong) NSNumber *fansCount;
/**
 *  收藏数量
 */
LC_PROPERTY(strong) NSNumber *favorCount;
/**
 *  屏蔽用户
 */
LC_PROPERTY(assign) BOOL isBlocked;

@end
