//
//  LKLocalUser.m
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLocalUser.h"
#import "AppDelegate.h"
#import "LCKeychain.h"
#import "LCEncryptorAES.H"

#define LK_CURRENT_USER @"LKCurrentUser.Key"
#define LK_USER_CACHE(uid) LC_NSSTRING_FORMAT(@"LKUserCache.Key.%@",uid)

#define LK_SESSION_TOKEN @"LKSession.Token.Key"
#define LK_REFRESH_TOKEN @"LKRefresh.Token.Key"
#define LK_EXPIRES_IN @"LKExpires.In.Key"

#define LK_AES_KEY @"abcdefgz"
#define LK_VI_KEY @"zgfedcba"

@interface LKLocalUser ()

LC_PROPERTY(strong) LKUser * user;

@end

@implementation LKLocalUser

+ (void)login:(NSDictionary *)rawUserInfo {
    [LKLocalUser.singleton login:rawUserInfo];
}

+ (void)logout {
    [LKLocalUser.singleton logoutCurrentUser];
}

- (BOOL)isLogin {
    NSString * uid = self[LK_CURRENT_USER];
    return uid ? YES : NO;
}

- (void)setSessionToken:(NSString *)sessionToken {
    if (!sessionToken) return;
    [LCKeychain setObject:sessionToken forKey:LK_SESSION_TOKEN];
    NSString *tmpToken = [LCKeychain objectForKey:LK_SESSION_TOKEN];
    if (!tmpToken) {
        self[LK_SESSION_TOKEN] = [LCEncryptorAES encryptString:sessionToken keyString:LK_AES_KEY ivString:LK_VI_KEY];
    }
}

- (NSString *)sessionToken {
    NSString *tmpToken = [LCKeychain objectForKey:LK_SESSION_TOKEN];
    if (!tmpToken) {
        tmpToken = [LCEncryptorAES decryptData:self[LK_SESSION_TOKEN] keyString:LK_AES_KEY ivString:LK_VI_KEY];
    }
    return tmpToken;
}

- (void)setRefreshToken:(NSString *)refreshToken {
    if (!refreshToken) return;
    [LCKeychain setObject:refreshToken forKey:LK_REFRESH_TOKEN];
    NSString *tmpToken = [LCKeychain objectForKey:LK_REFRESH_TOKEN];
    if (!tmpToken) {
        self[LK_REFRESH_TOKEN] = [LCEncryptorAES encryptString:refreshToken keyString:LK_AES_KEY ivString:LK_VI_KEY];
    }
}

- (NSString *)refreshToken {
    NSString *tmpToken = [LCKeychain objectForKey:LK_REFRESH_TOKEN];
    if (!tmpToken) {
        tmpToken = [LCEncryptorAES decryptData:self[LK_REFRESH_TOKEN] keyString:LK_AES_KEY ivString:LK_VI_KEY];
    }
    return tmpToken;
}

- (void)setExpiresIn:(NSString *)expiresIn {
    if (!expiresIn) return;
    [LCKeychain setObject:expiresIn forKey:LK_EXPIRES_IN];
    
    NSString *tmpToken = [LCKeychain objectForKey:LK_EXPIRES_IN];
    if (!tmpToken) {
        self[LK_EXPIRES_IN] = [LCEncryptorAES encryptString:expiresIn keyString:LK_AES_KEY ivString:LK_VI_KEY];
    }
}

- (NSString *)expiresIn {
    NSString *tmpToken = [LCKeychain objectForKey:LK_EXPIRES_IN];
    if (!tmpToken || tmpToken.length == 0) {
        tmpToken = [LCEncryptorAES decryptData:self[LK_EXPIRES_IN] keyString:LK_AES_KEY ivString:LK_VI_KEY];
    }
    return tmpToken;
}

- (instancetype)init {
    if (self = [super initWithPath:[[LCSanbox documentPath] stringByAppendingString:@"/LKUser.db"]]) {
        NSString * uid = self[LK_CURRENT_USER];
        if (uid) {
            self.rawUserInfo = self[LK_USER_CACHE(uid)];
            self.user = [[LKUser alloc] initWithDictionary:self.rawUserInfo error:nil];
            if (!self.user.id) {
                self.user = [[LKUser alloc] init];
                self.user.id = @(uid.integerValue);
            }
            // 如果keychain没存数据，先存上
//            id keyChainValue = [LCKeychain objectForKey:LK_CURRENT_USER];
//            if (!keyChainValue) {
//                [LCKeychain setObject:self.rawUserInfo forKey:LK_CURRENT_USER];
//                [LCKeychain setObject:self.expiresIn forKey:LK_EXPIRES_IN];
//                [LCKeychain setObject:self.sessionToken forKey:LK_SESSION_TOKEN];
//                [LCKeychain setObject:self.refreshToken forKey:LK_REFRESH_TOKEN];
//            }
        }
    }
    
    return self;
}

- (void)login:(NSDictionary *)rawUserInfo {
    self.rawUserInfo = rawUserInfo;
    NSNumber * uid = rawUserInfo[@"user_id"];
    self[LK_CURRENT_USER] = uid;
    self[LK_USER_CACHE(uid)] = rawUserInfo;
    if (rawUserInfo) {
        // 更新keychain数据
        [LCKeychain setObject:[rawUserInfo JSONString] forKey:LK_CURRENT_USER];
    }
}

- (void)logoutCurrentUser {
    self.rawUserInfo = nil;
    self.user = nil;
    self[LK_CURRENT_USER] = nil;
    [LCKeychain removeObjectForKey:LK_SESSION_TOKEN];
    [LCKeychain removeObjectForKey:LK_REFRESH_TOKEN];
    [LCKeychain removeObjectForKey:LK_EXPIRES_IN];
    [LCKeychain removeObjectForKey:LK_CURRENT_USER];
}

- (void)setRawUserInfo:(NSDictionary *)rawUserInfo {
    if (!rawUserInfo) {
        _rawUserInfo = nil;
        _user = nil;
        return;
    }
    _rawUserInfo = rawUserInfo;
    _user = [LKUser objectFromDictionary:rawUserInfo];
}

- (void)updateCurrentUserInfo:(NSDictionary *)rawUserInfo {
    self[LK_USER_CACHE(self.user.id)] = rawUserInfo;
    [self setRawUserInfo:rawUserInfo];
}

+ (void)regetSessionTokenAndUseLoadingTip:(BOOL)useLoadingTip {
    if (!LKLocalUser.singleton.isLogin) {
        return;
    }
    
    if (useLoadingTip) {
        [LC_KEYWINDOW showTopLoadingMessageHud:LC_LO(@"重新登录中...")];
    }
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"user/%@/refreshtoken", LKLocalUser.singleton.user.id]].PUT_METHOD();
    [interface addParameter:LKLocalUser.singleton.refreshToken key:@"refresh_token"];
    
    [LKLocalUser.singleton request:interface complete:^(LKHttpRequestResult *result) {
        if (result.state == LKHttpRequestStateFinished) {
            if (useLoadingTip) {
                [RKDropdownAlert dismissAllAlert];
            }
            NSDictionary * data = result.json[@"data"];
            LKLocalUser.singleton.sessionToken = data[@"session_token"];
            LKLocalUser.singleton.refreshToken = data[@"refresh_token"];
            LKLocalUser.singleton.expiresIn = data[@"expires_in"];
        } else if (result.state == LKHttpRequestStateFailed){
            if (useLoadingTip) {
                [RKDropdownAlert dismissAllAlert];
            }
            [LKLocalUser.singleton postNotification:LKSessionError withObject:@(4013)];
        }
        
    }];
}


@end
