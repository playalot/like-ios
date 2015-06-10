//
//  LC_AppVersion.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-8.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCAppVersion.h"

#pragma mark -

static NSString * const appVersionAppLookupURLFormat = @"http://itunes.apple.com/%@/lookup";

#pragma mark -

@implementation NSString(LCAppVersion)

- (NSComparisonResult)compareVersion:(NSString *)version
{
    return [self compare:version options:NSNumericSearch];
}

- (NSComparisonResult)compareVersionDescending:(NSString *)version
{
    switch ([self compareVersion:version])
    {
        case NSOrderedAscending:
        {
            return NSOrderedDescending;
        }
        case NSOrderedDescending:
        {
            return NSOrderedAscending;
        }
        default:
        {
            return NSOrderedSame;
        }
    }
}

@end

#pragma mark -

@interface LCAppVersion ()

@end

#pragma mark -

@implementation LCAppVersion


-(LCAppVersion *) init
{
    LC_SUPER_INIT({
    
        self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        if ([self.applicationVersion length] == 0){
            
            self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        }
        
        self.appStoreCountry = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];

        self.autoPresentedUpdateAlert = YES;
        
        self.hasNewVersion = NO;
        self.theNewVersionDetails = nil;
        self.theNewVersionNumber = nil;
        self.theNewVersionURL = nil;
        
        
        self.alertStyle = LCAppVersionAlertStyleAlert;
        self.updateButtonTitle = LC_LO(@"马上更新");
        self.cancelButtonTitle = LC_LO(@"下次再说");
    });
}

+(void) checkForNewVersion
{
    [LCAppVersion.singleton checkForNewVersion];
}

-(void) checkForNewVersion
{
    [self cancelAllRequests];

    NSString * iTunesServiceURL = [NSString stringWithFormat:appVersionAppLookupURLFormat, @"US"];

    iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?bundleId=%@",[LCSystemInfo appIdentifier]];
    
    @weakly(self);
    
    self.GET(iTunesServiceURL, ^(LCHTTPRequestResult * result){
    
        @normally(self);
        
        if (!result.error) {
            
            NSDictionary * resultData = result.responseObject;
            
            if ([[resultData objectForKey:@"resultCount"] intValue] == 0) {
                
                INFO(@"[LCAppVersion] App version check failed : can't find the \"%@\" application in AppStore.",[LCSystemInfo appIdentifier]);
                
            }else{
                
                NSArray * applicationInfos = [resultData objectForKey:@"results"];
                
                __block NSInteger resultIndex = -1;
                __block NSString * newVersionNumber = nil;
                
                [applicationInfos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                    
                    NSString * appStoreVersion = [obj objectForKey:@"version"];
                    
                    BOOL newerVersionAvailable = ([appStoreVersion compareVersion:self.applicationVersion] == NSOrderedDescending);
                    
                    if (newerVersionAvailable) {
                        resultIndex = idx;
                        newVersionNumber = appStoreVersion;
                    }
                    
                }];
                
                if (newVersionNumber) {
                    
                    INFO(@"[LCAppVersion] Check finished : new %@",newVersionNumber);
                    self.hasNewVersion = YES;
                    self.theNewVersionNumber  = newVersionNumber;
                    self.theNewVersionURL     = [[applicationInfos objectAtIndex:resultIndex] objectForKey:@"trackViewUrl"];
                    self.theNewVersionDetails = [[applicationInfos objectAtIndex:resultIndex] objectForKey:@"releaseNotes"];
                    self.theNewVersionIconURL = [[applicationInfos objectAtIndex:resultIndex] objectForKey:@"artworkUrl60"];
                    
                }else{
                    INFO(@"[LCAppVersion] Check finished : no new version.");
                    //                self.hasNewVersion = NO;
                    //                self.theNewVersionDetails = nil;
                    //                self.theNewVersionNumber = nil;
                    //                self.theNewVersionURL = nil;
                }
                
                if (self.checkFinishBlock) {
                    self.checkFinishBlock(self, self.hasNewVersion);
                }
                
                if (self.autoPresentedUpdateAlert) {
                    [self showNewVersionUpdateAlert];
                }
            }
        }
        else{
            
            INFO(@"[LCAppVersion] Check failed : %@", result.error);
            
            if (self.checkFinishBlock) {
                self.checkFinishBlock(self, self.hasNewVersion);
            }
        }
    
    });
}

-(void) showNewVersionUpdateAlert
{
    if (!self.hasNewVersion) {
        return;
    }
    
    
    if (self.alertStyle == LCAppVersionAlertStyleAlert) {
        
        NSString * title = LC_NSSTRING_FORMAT(@"%@:%@",LC_LO(@"发现新版本"), self.theNewVersionNumber);
        
        @weakly(self);
        
        LCUIAlertView.VIEW.MESSAGE(self.theNewVersionDetails).TITLE(title).CANCEL(self.cancelButtonTitle).OTHER(self.updateButtonTitle).SHOW().DID_TOUCH = ^(NSInteger index){
          
            @normally(self);
            
            if (index != 0) {
                
                if (self.updateButtonClickBlock) {
                    self.updateButtonClickBlock(self);
                }
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.theNewVersionURL]];
            }
        };
        
    }
}

@end
