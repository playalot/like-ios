//
//  NSObject+IFNetworkInterface.m
//  IFAPP
//
//  Created by Leer on 14/12/30.
//  Copyright (c) 2014年 Licheng Guo . ( http://nsobject.me ). All rights reserved.
//

#import "NSObject+LKNetworkInterface.h"
#import "LKNetworkCenter.h"

@implementation NSObject (LKNetworkInterface)

-(BOOL) request:(LKHttpRequestInterface *)request complete:(LKHTTPRequestComplete)complete
{
    return [LKNetworkCenter request:request sender:self complete:complete];
}

@end
