//
//  IFHttpRequestInterface.h
//  IFAPP
//
//  Created by Leer on 14/12/30.
//  Copyright (c) 2014年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "LCNetworkCenter.h"

typedef NS_ENUM(NSInteger, LKHttpRequestState) {
    
    LKHttpRequestStateFinished,
    LKHttpRequestStateFailed,
    LKHttpRequestStateCanceled,
    LKHttpRequestStateUpdate,
};

typedef NS_ENUM(NSInteger, LKHttpRequestMethodType) {
    
    LKHttpRequestMethodTypeGet = LCHTTPRequestMethodGet,
    LKHttpRequestMethodTypePost = LCHTTPRequestMethodPost,
    LKHttpRequestMethodTypePut = LCHTTPRequestMethodPut,
    LKHttpRequestMethodTypeDelete = LCHTTPRequestMethodDelete,
};

@interface LKHttpRequestResult : NSObject

LC_PROPERTY(assign) LKHttpRequestState state;
LC_PROPERTY(strong) NSNumber * errorCode;
LC_PROPERTY(strong) NSString * error;
LC_PROPERTY(strong) id json;
LC_PROPERTY(assign) CGFloat progress;

+ (instancetype)result;

@end

LC_BLOCK(LKHttpRequestInterface *, LKHttpRequestInterfaceAutoSession, ());
LC_BLOCK(LKHttpRequestInterface *, LKHttpRequestInterfaceType, ());

@interface LKHttpRequestInterface : NSObject

LC_PROPERTY(assign) LCHTTPRequestMethod methodType;
LC_PROPERTY(copy) NSString *type;
LC_PROPERTY(readonly) NSDictionary *interfaceParameters;
LC_PROPERTY(copy) NSString *sessionToken;


LC_PROPERTY(readonly) LKHttpRequestInterfaceAutoSession AUTO_SESSION;
LC_PROPERTY(readonly) LKHttpRequestInterfaceType GET_METHOD;
LC_PROPERTY(readonly) LKHttpRequestInterfaceType POST_METHOD;
LC_PROPERTY(readonly) LKHttpRequestInterfaceType PUT_METHOD;
LC_PROPERTY(readonly) LKHttpRequestInterfaceType DELETE_METHOD;


+(instancetype) interface;
+(instancetype) interfaceType:(NSString *)type;

-(void) addParameter:(id<NSCopying>)value key:(id<NSCopying>)key;

@end


LC_BLOCK(NSString *, URLCode, ());

@interface NSObject (LKHttpRequestInterface)

LC_PROPERTY(readonly) URLCode URLCODE;

@end
