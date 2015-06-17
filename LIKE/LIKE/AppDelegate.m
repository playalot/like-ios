//
//  AppDelegate.m
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "AppDelegate.h"
#import "LKLoginViewController.h"
#import "LCCMD.h"
#import "LKAssistiveTouchButton.h"
#import "LKWelcome.h"
#import "MobClick.h"
#import "LKWeChatShare.h"
#import "LKSinaShare.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "LKNotificationCount.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate () <LC_CMD_IMP>

LC_PROPERTY(strong) TencentOAuth * tencentOAuth;
LC_PROPERTY(assign) NSTimeInterval enterBackgroundTimeInterval;

@end

@implementation AppDelegate


-(void) load
{
    // 全局容错
    [LCSwizzle beginFaultTolerant];
    
    
    // Debugger
    [LCDebugger sharedInstance];
    
    
    //微信
    [WXApi registerApp:@"wxa3f301de2a84df8b"];
    
    
    //qq
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1104653828" andDelegate:nil];
    
    
    //微博
    [WeiboSDK registerApp:@"2142262721"];
    
    
    // UMeng
    [MobClick startWithAppkey:@"54bf7949fd98c563bc00075d" reportPolicy:SENDWIFIONLY channelId:@"App Store"];
    
    
    // CMD
    [LCCMD addObjectCMD:@"session" CMDType:LC_CMD_TYPE_SEE IMPObject:self CMDDescription:@"User session."];
    [LCCMD addObjectCMD:@"uid" CMDType:LC_CMD_TYPE_SEE IMPObject:self CMDDescription:@"User id."];
    [LCCMD addObjectCMD:@"refreshtoken" CMDType:LC_CMD_TYPE_SEE IMPObject:self CMDDescription:@"Refresh token."];

    
    
    [self observeNotification:LKSessionError];
    [self observeNotification:LCUIApplicationDidRegisterRemoteNotification];
    [self observeNotification:LCUIApplicationDidRegisterRemoteFailNotification];
    
    
    self.home = [LKHomeViewController viewController];
    
    
    self.tabBarController = [[LKTabBarController alloc] initWithViewControllers:@[LC_UINAVIGATION(self.home)]];
    
    self.window.rootViewController = self.tabBarController;
    

    // welcom...
    [LKWelcome welcome];
    
    
    
    if (IOS8_OR_LATER) {
        
        UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self cancelAllTimers];
    
    self.enterBackgroundTimeInterval = 0;
    
    [self fireTimer:@"Timing" timeInterval:1 repeat:YES];
}

-(void) applicationWillEnterForeground:(UIApplication *)application
{
    [self cancelAllTimers];
    
    if (LKLocalUser.singleton.isLogin) {
     
        if (LKLocalUser.singleton.expiresIn) {
            
            // 判断是否授权过期
            // 两天以内就重新授权
            NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval beforeInterval = [LKLocalUser.singleton.expiresIn doubleValue];
            
            if (nowInterval - beforeInterval < 86400 * 2) {
                
                [LKLocalUser regetSessionTokenAndUseLoadingTip:NO];
            }
        }
        
        [LKNotificationCount startCheck];
    }
    
    if (self.enterBackgroundTimeInterval > 60 * 2) {
        
        [self postNotification:LKHomeViewControllerReloadingData];
    }
}

-(void) handleTimer:(NSTimer *)timer
{
    self.enterBackgroundTimeInterval += 1.0;
}

-(NSString *) CMDSee:(NSString *)cmd
{
    if ([cmd isEqualToString:@"session"]) {
        
        return LKLocalUser.singleton.sessionToken;
    }
    else if ([cmd isEqualToString:@"uid"]){
        
        return [NSString stringWithFormat:@"%@",LKLocalUser.singleton.user.id];
    }
    else if ([cmd isEqualToString:@"refreshtoken"]){
        
        return LKLocalUser.singleton.refreshToken;
    }
        
    return @"";
}

-(void) handleNotification:(NSNotification *)notification
{
    if ([notification is:LKSessionError]) {
        
        NSInteger errorCode = [notification.object integerValue];
        
        if (errorCode == 4016) {
            
            [LKLocalUser regetSessionTokenAndUseLoadingTip:YES];
        }
        else if (errorCode == 4013){
            
            [LKLocalUser logout];
            [LKLoginViewController needLoginOnViewController:nil];
        }
    }
    else if ([notification is:LCUIApplicationDidRegisterRemoteNotification]){
    
        if (LKLocalUser.singleton.isLogin) {
            
            LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"installation"].AUTO_SESSION().POST_METHOD();
            
            [interface addParameter:@"ios" key:@"device_type"];
            [interface addParameter:notification.object key:@"device_token"];
            
            [self request:interface complete:^(LKHttpRequestResult *result) {
                
                ;
                
            }];

        }
    }
    else if ([notification is:LCUIApplicationDidRegisterRemoteFailNotification]){
        
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [QQApiInterface handleOpenURL:url delegate:nil];
    
    [WXApi handleOpenURL:url delegate:LKWeChatShare.singleton];
    
    [WeiboSDK handleOpenURL:url delegate:LKSinaShare.singleton];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];

    return YES;
}

@end
