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
#import "LKWelcome.h"
#import "MobClick.h"
#import "LKWeChatShare.h"
#import "LKSinaShare.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "LKNotificationCount.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <MAMapKit/MAMapKit.h>

@interface AppDelegate () <LC_CMD_IMP>

LC_PROPERTY(strong) TencentOAuth * tencentOAuth;
LC_PROPERTY(assign) NSTimeInterval enterBackgroundTimeInterval;

@end

@implementation AppDelegate


-(void) load:(NSDictionary *)launchOptions
{
    [MAMapServices sharedServices].apiKey = @"4c0db296d4f4d092fdaa9004ee8c959a";

    
    // 全局容错
    [LCSwizzle beginFaultTolerant];
    
    
    // Debugger
    [LCDebugger sharedInstance];
    
    
    // 微信
    [WXApi registerApp:@"wxa3f301de2a84df8b"];
    
    
    // qq
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1104653828" andDelegate:nil];
    
    
    // facebook
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];

    
    // 微博
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
    [self observeNotification:LCUIApplicationDidReceiveRemoteNotification];
    
    
    self.home = [LKHomeViewController viewController];
    
    
    self.tabBarController = [[LKTabBarController alloc] initWithViewControllers:@[LC_UINAVIGATION(self.home)]];
    
    self.window.rootViewController = self.tabBarController;
    

    
    if (IOS8_OR_LATER) {
        
        UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    
    // 判断是否为推送打开
    if (LKLocalUser.singleton.isLogin && launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
        [self.home performSelector:@selector(notificationAction) withObject:nil afterDelay:0.5];
    }

    
    if (!LKLocalUser.singleton.isLogin) {

    LCUIImageView * imageView = LCUIImageView.view;
    imageView.image = [LKWelcome image];
    imageView.viewFrameWidth = LC_DEVICE_WIDTH;
    imageView.viewFrameHeight = LC_DEVICE_HEIGHT + 20;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [LC_KEYWINDOW addSubview:imageView];
    
    [LCUIApplication presentViewController:LKLoginViewController.viewController];
        
        [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            imageView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [imageView removeFromSuperview];
            
        }];
    }

//    // welcom...
//    [LKWelcome welcome];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *) getCurrentViewController
{
    UIViewController * result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    if (window.windowLevel != UIWindowLevelNormal){
        
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        for(UIWindow * tmpWin in windows){
            
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView * frontView = [[window subviews] objectAtIndex:0];
    
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
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
    
    if (self.enterBackgroundTimeInterval > 60 * 5) {
        
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
            
            [self request:interface complete:^(LKHttpRequestResult * result) {
                
            }];

        }
    }
    else if ([notification is:LCUIApplicationDidRegisterRemoteFailNotification]){
        
    }
    else if ([notification is:LCUIApplicationDidReceiveRemoteNotification]){
        
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [super application:application didReceiveRemoteNotification:userInfo];
    
    if ( application.applicationState == UIApplicationStateActive ){
        // app was already in the foreground
    }else{
        
        if (LKLocalUser.singleton.isLogin) {
            
            [self.home performSelector:@selector(notificationAction) withObject:nil afterDelay:0.5];
        }
    }
}

@end
