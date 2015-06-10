//
//  LKFriendshipModel.h
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCHTTPRequestModel.h"

LC_BLOCK(void, LKFriendshipModelRequestFinished, (NSNumber * newFriendship, NSString * error));

@interface LKFriendshipModel : LCHTTPRequestModel

+(void) friendshipAction:(LKUser *)user requestFinished:(LKFriendshipModelRequestFinished)requestFinished;

@end
