//
//  LKSMSLoginInterface.h
//  LIKE
//
//  Created by huangweifeng on 10/15/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"

@interface LKSMSLoginInterface : LKBaseInterface

LC_PROPERTY(copy) NSString *zone;
LC_PROPERTY(copy) NSString *mobile;
LC_PROPERTY(copy) NSString *code;

- (NSString *)sessionToken;

- (NSString *)refreshToken;

- (NSNumber *)expiresIn;

- (NSNumber *)userId;

@end
