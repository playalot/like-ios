//
//  LC_AppVersion.h
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-8.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <Foundation/Foundation.h>



@class LCAppVersion;

typedef NS_ENUM (NSInteger, LCAppVersionAlertStyle)
{
    LCAppVersionAlertStyleAlert = 0,
};

LC_BLOCK(void, LCAppVersionCheckFinished, (LCAppVersion * appVersion, BOOL hasNewVersion));
LC_BLOCK(void, LCAppVersionUpdateButtonClicked, (LCAppVersion * appVersion));
         
#pragma mark -

@interface LCAppVersion : NSObject


LC_PROPERTY(strong) NSString * applicationVersion;
LC_PROPERTY(strong) NSString * appStoreCountry;


// Action blocks
LC_PROPERTY(copy) LCAppVersionCheckFinished       checkFinishBlock;
LC_PROPERTY(copy) LCAppVersionUpdateButtonClicked updateButtonClickBlock;


// Setting UI
LC_PROPERTY(assign) BOOL autoPresentedUpdateAlert; //是否自动弹出升级提示框 default is YES
LC_PROPERTY(assign) LCAppVersionAlertStyle alertStyle;

LC_PROPERTY(strong) NSString * updateButtonTitle;
LC_PROPERTY(strong) NSString * cancelButtonTitle;


LC_PROPERTY(assign) BOOL hasNewVersion;


// If hasNewVersion is YES
LC_PROPERTY(strong) NSString * theNewVersionNumber;
LC_PROPERTY(strong) NSString * theNewVersionURL;
LC_PROPERTY(strong) NSString * theNewVersionDetails;
LC_PROPERTY(strong) NSString * theNewVersionIconURL;


+(void) checkForNewVersion;

@end
