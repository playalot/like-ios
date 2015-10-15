//
//  IFHttpRequestInterface.m
//  IFAPP
//
//  Created by Leer on 14/12/30.
//  Copyright (c) 2014年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "LKHttpRequestInterface.h"

@implementation LKHttpRequestResult

+(instancetype) result
{
    return [[LKHttpRequestResult alloc] init];
}

-(id) init
{
    LC_SUPER_INIT({
        
        self.state = LKHttpRequestStateFinished;
        self.errorCode = @(0);
        self.error = @"";
        self.json = nil;
    })
}

@end

@interface LKHttpRequestInterface ()

LC_PROPERTY(strong) NSMutableDictionary * parameters;

@end

@implementation LKHttpRequestInterface


+(instancetype) interfaceType:(NSString *)type
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interface];
    interface.type = type;
    return interface;
}

+(instancetype) interface
{
    return [[LKHttpRequestInterface alloc] init];
}

-(instancetype) init
{
    if (self = [super init]) {
        
        self.parameters = [NSMutableDictionary dictionary];
    };
    
    return self;
    
}

-(void) addParameter:(id<NSCopying,NSObject>)value key:(id<NSCopying>)key
{
    if (!value || !key) {
        
        ERROR(@"Value or key can't be nil. (%@ %@)",value,key);
        return;
    }
    
    NSString * des = [NSString stringWithFormat:@"%@",value];
    
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSArray class]]) {
        
        self.parameters[key] = value;
        return;
    }
    
    self.parameters[key] = des;
}

-(NSDictionary *) interfaceParameters
{
    NSMutableDictionary * p = [self.parameters mutableCopy];
    
    return p;
}

-(void) setType:(NSString *)type
{
    _type = type;
}

-(LKHttpRequestInterfaceAutoSession) AUTO_SESSION {
    LKHttpRequestInterfaceAutoSession block = ^(){
        if (LKLocalUser.singleton.isLogin) {
            self.sessionToken = LKLocalUser.singleton.sessionToken;
        }
        return self;
    };
    return block;
}

-(LKHttpRequestInterfaceType) GET_METHOD
{
    LKHttpRequestInterfaceType block = ^ LKHttpRequestInterface * (){
        
        self.methodType = LKHttpRequestMethodTypeGet;
        return self;
    };
    
    return block;
}

-(LKHttpRequestInterfaceType) POST_METHOD
{
    LKHttpRequestInterfaceType block = ^ LKHttpRequestInterface * (){
        
        self.methodType = LKHttpRequestMethodTypePost;
        return self;
    };
    
    return block;
}

-(LKHttpRequestInterfaceType) PUT_METHOD
{
    LKHttpRequestInterfaceType block = ^ LKHttpRequestInterface * (){
        
        self.methodType = LKHttpRequestMethodTypePut;
        return self;
    };
    
    return block;
}

-(LKHttpRequestInterfaceType) DELETE_METHOD
{
    LKHttpRequestInterfaceType block = ^ LKHttpRequestInterface * (){
        
        self.methodType = LKHttpRequestMethodTypeDelete;
        return self;
    };
    
    return block;
}

@end

@implementation NSObject (IFHttpRequestInterface)

-(URLCode) URLCODE
{
    URLCode block = ^(){
        
        return [self.description stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
    };
    
    return block;
}

@end
