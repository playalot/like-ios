//
//  LKBaseInterface.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKBaseInterface.h"
#import "LKUserDefaults.h"

@implementation LKBaseInterface

- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSString *sessionToken = LKLocalUser.singleton.sessionToken;
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
    if (sessionToken) {
        [resultDic setValue:sessionToken forKey:@"LIKE-SESSION-TOKEN"];
    }
    // Default Header
    
    // Json Content Type
    [resultDic setValue:@"application/json" forKey:@"Content-Type"];
    
    // Accept Encoding
    [resultDic setValue:@"gzip" forKey:@"Accept-Encoding"];
    
    // 长宽
    CGFloat width = LC_DEVICE_WIDTH * (UI_IS_IPHONE6PLUS ? 3 : 2);
    [resultDic setValue:@(width).description forKey:@"LIKE-SCREEN-WIDTH"];
    
    // Language code
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    [resultDic setValue:languageCode forKey:@"Accept-Language"];
    
    // 获取当前App版本号
    NSString *appVersion = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];
    [resultDic setValue:appVersion forKey:@"LIKE-VERSION"];
    
    if (LCNetwork.singleton.netWorkStatus == LCNetworkStatusViaWiFi) {
        [resultDic setValue:@"YES" forKey:@"LIKE-WIFI"];
    }
    
    return resultDic;
}

- (NSInteger)errorCode {
    return [self.responseJSONObject[@"code"] integerValue];
}

- (NSString *)errorMessage {
    return self.responseJSONObject[@"message"];
}

@end
