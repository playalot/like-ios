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
#import "AFNetworkActivityIndicatorManager.h"

@interface AppDelegate () <LC_CMD_IMP>

LC_PROPERTY(strong) TencentOAuth * tencentOAuth;
LC_PROPERTY(assign) NSTimeInterval enterBackgroundTimeInterval;

@end

@implementation AppDelegate

/**
 *  应用程序启动就会调用此方法
 */
-(void) load:(NSDictionary *)launchOptions
{
    
    // 1.设置缓存
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:cache];
    
    // 2.设置网络指示器
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    
    
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

    
    // 会话错误通知
    [self observeNotification:LKSessionError];
    // 应用程序远程登录通知
    [self observeNotification:LCUIApplicationDidRegisterRemoteNotification];
    // 应用程序远程登录失败通知
    [self observeNotification:LCUIApplicationDidRegisterRemoteFailNotification];
    // 应用程序接收到远程通知
    [self observeNotification:LCUIApplicationDidReceiveRemoteNotification];
    
    
    self.home = [LKHomeViewController viewController];
    
    
    if (IOS8_OR_LATER) {
        
        // 若系统为iOS 8以后的版本,需要注册通知
        UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    // Please notify the application each time the orientation is changed.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    
    // 判断是否为推送打开
    if (LKLocalUser.singleton.isLogin && launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
        [self.home performSelector:@selector(notificationAction) withObject:nil afterDelay:0.5];
    }

    // tabbarCtrl只放了一个主页控制器
    self.tabBarController = [[LKTabBarController alloc] initWithViewControllers:@[LC_UINAVIGATION(self.home)]];
    
    self.window.rootViewController = self.tabBarController;
    
    
    if (!LKLocalUser.singleton.isLogin) {


        LCUIImageView * imageView = LCUIImageView.view;
        imageView.image = [LKWelcome image];
        imageView.viewFrameWidth = LC_DEVICE_WIDTH;
        imageView.viewFrameHeight = LC_DEVICE_HEIGHT + 20;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [LC_KEYWINDOW addSubview:imageView];
        
        LKLoginViewController * login = LKLoginViewController.viewController;
        [login view];
        
        [self.tabBarController presentViewController:login animated:NO completion:^{
            
            [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                
                imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                imageView.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                [imageView removeFromSuperview];
                
            }];
        }];
        
        
    }

//    // welcom...
//    [LKWelcome welcome];
}

/**
 *  禁止屏幕转向
 */
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

/**
 *  获取当前的控制器
 */
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

/**
 *  应用程序已经进入后台的时候调用
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self cancelAllTimers];
    
    // 重置进入后台时间
    self.enterBackgroundTimeInterval = 0;
    
    // 启动定时器
    [self fireTimer:@"Timing" timeInterval:1 repeat:YES];
}

/**
 *  应用程序将要进入前台的时候调用
 */
-(void) applicationWillEnterForeground:(UIApplication *)application
{
    // 取消所有的定时器操作
    [self cancelAllTimers];
    
    // 是否登录
    if (LKLocalUser.singleton.isLogin) {
     
        // 是否过期
        if (LKLocalUser.singleton.expiresIn) {
            
            // 判断是否授权过期
            // 两天以内就重新授权
            NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval beforeInterval = [LKLocalUser.singleton.expiresIn doubleValue];
            
            if (nowInterval - beforeInterval < 86400 * 2) {
                
                // 过期,重新登录,并设置badge
                [LKLocalUser regetSessionTokenAndUseLoadingTip:NO];
            }
        }
        
        // 检查通知数量
        [LKNotificationCount startCheck];
    }
    
    if (self.enterBackgroundTimeInterval > 60 * 5) {
        
        // 进入后台超过5分钟,发送重新加载数据的通知
        [self postNotification:LKHomeViewControllerReloadingData];
    }
}

/**
 *  进入后台时间累加1s
 */
-(void) handleTimer:(NSTimer *)timer
{
    self.enterBackgroundTimeInterval += 1.0;
}

#pragma mark - ***** LC_CMD_IMP *****
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

/**
 *  根据通知类型处理对应的操作
 */
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
                
                // TODO
            }];

        }
    }
    else if ([notification is:LCUIApplicationDidRegisterRemoteFailNotification]){
        
    }
    else if ([notification is:LCUIApplicationDidReceiveRemoteNotification]){
        
    }
}

/**
 *  应用回调时调用此方法
 *
 *  @param application       应用程序
 *  @param url               url
 *  @param sourceApplication 源应用程序
 *  @param annotation        注释
 *
 *  @return YES
 */
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

/**
 *  接收到远程通知的时候调用
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [super application:application didReceiveRemoteNotification:userInfo];
    
    // 判断是否是活动状态
    if ( application.applicationState == UIApplicationStateActive ){
        // app was already in the foreground
    }else{
        // 判断本地用户是否是登录状态
        if (LKLocalUser.singleton.isLogin) {
            
            [self.home performSelector:@selector(notificationAction) withObject:nil afterDelay:0.5];
        }
    }
}

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    
//    // 1.设置缓存
//    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
//    [NSURLCache setSharedURLCache:cache];
//    
//    // 2.设置网络指示器
//    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
//    
//    return YES;
//}

@end
