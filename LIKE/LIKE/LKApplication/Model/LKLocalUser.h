//
//  LKLocalUser.h
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LCUserDefaults.h"
#import "LKUser.h"

@interface LKLocalUser : LCUserDefaults

LC_PROPERTY(readonly) BOOL isLogin;
LC_PROPERTY(readonly) LKUser * user;
LC_PROPERTY(strong) NSString * sessionToken;
LC_PROPERTY(strong) NSString * refreshToken;
LC_PROPERTY(strong) NSString * expiresIn;
LC_PROPERTY(strong) NSDictionary * rawUserInfo;

+(void) login:(NSDictionary *)rowUserInfo;

+(void) logout;

-(void) updateCurrentUserInfo:(NSDictionary *)rawUserInfo;

+(void) regetSessionTokenAndUseLoadingTip:(BOOL)useLoadingTip;

@end
