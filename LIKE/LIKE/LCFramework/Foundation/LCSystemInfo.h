//
//  LC_SystemInfo.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-9-16.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

    #define IOS8_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
    #define IOS7_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
    #define IOS6_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"6.0"] != NSOrderedAscending )
    #define IOS5_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"5.0"] != NSOrderedAscending )
    #define IOS4_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"4.0"] != NSOrderedAscending )
    #define IOS3_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"3.0"] != NSOrderedAscending )

#else

    #define IOS7_OR_LATER   (NO)
    #define IOS6_OR_LATER	(NO)
    #define IOS5_OR_LATER	(NO)
    #define IOS4_OR_LATER	(NO)
    #define IOS3_OR_LATER	(NO)

#endif

@interface LCSystemInfo : NSObject

+ (BOOL)isPhoneRetina4;
+ (BOOL)isPhoneRetina5;
+ (BOOL)isPhone6Plus;

+ (NSString *)appVersion;
+ (NSString *)appBuildVersion;
+ (NSString *)appIdentifier;
+ (NSString *)deviceModel;

/* Simulate low memory warning. */
+ (void)simulateLowMemoryWarning;

#pragma mark - 

+ (CGFloat) cpuUsed;
+ (NSString *) freeDiskSpace;

+ (uint64_t)getSysCtl64WithSpecifier:(char*)specifier;

@end
