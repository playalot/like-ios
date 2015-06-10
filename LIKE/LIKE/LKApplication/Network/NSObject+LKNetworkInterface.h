//
//  NSObject+IFNetworkInterface.h
//  IFAPP
//
//  Created by Leer on 14/12/30.
//  Copyright (c) 2014年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "LKNetworkCenter.h"
#import "LKHttpRequestInterface.h"

@interface NSObject (LKNetworkInterface)

-(BOOL) request:(LKHttpRequestInterface *)request complete:(LKHTTPRequestComplete)complete;

@end
