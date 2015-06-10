//
//  IFNetworkCenter.h
//  IFAPP
//
//  Created by Leer on 14/12/30.
//  Copyright (c) 2014年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

@class LKHttpRequestInterface, LKHttpRequestResult;

LC_BLOCK(void, LKHTTPRequestComplete, (LKHttpRequestResult * result));

@interface LKNetworkCenter : NSObject

+(BOOL) request:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete;

-(BOOL) request:(LKHttpRequestInterface *)interface sender:(NSObject *)sender complete:(LKHTTPRequestComplete)complete;

@end
