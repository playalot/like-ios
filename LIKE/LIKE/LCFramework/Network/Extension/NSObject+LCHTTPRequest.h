//
//  NSObject+LCHTTPRequest.h
//  LCFrameworkDemo
//
//  Created by Licheng Guo . http://nsobject.me/ on 15/4/2.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCNetworkCenter.h"

LC_BLOCK(NSURLSessionDataTask *, LCHTTPRequestBlockSN, (NSString * url, LCNetworkCenterBlock update));

@interface NSObject (LCHTTPRequest)

LC_PROPERTY(readonly) LCHTTPRequestBlockSN	GET;
LC_PROPERTY(readonly) LCHTTPRequestBlockSN	POST;
LC_PROPERTY(readonly) LCHTTPRequestBlockSN	PUT;
LC_PROPERTY(readonly) LCHTTPRequestBlockSN	DELETE;

- (void)cancelAllRequests;

@end
