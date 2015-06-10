//
//  LCDeviceIdentifier.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-3.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "LCDeviceIdentifier.h"
#import "LCKeychain.h"

@implementation LCDeviceIdentifier

+(NSString *) identifier
{
    NSString * udid = [LCDeviceIdentifier UDIDFromKeyChain];
    
    if (!udid) {
        
        udid = NSString.UUID;
        
        [LCDeviceIdentifier setUDIDToKeyChain:udid];
    }

    return udid;
}

+(NSString *) UDIDFromKeyChain
{
    return [LCKeychain objectForKey:@"LCFramework.Device.Identifier"];
}

+(void) setUDIDToKeyChain:(NSString *)udid
{
    [LCKeychain setObject:udid forKey:@"LCFramework.Device.Identifier"];
}

@end
