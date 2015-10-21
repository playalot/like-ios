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
#import <SMS_SDK/SMSSDK.h>
#import "SDImageCache.h"
#import "APService.h"
#import "RDVTabBarItem.h"
#import "LCNetworkConfig.h"
#import "LCUrlArgumentsFilter.h"
#import "LKNavigator.h"
#import "LKGateViewController.h"
#import "LCEncryptorAES.h"
#import "LKChooseInterestView.h"
#import "LKLoginViewIp4Controller.h"

@interface AppDelegate () <LC_CMD_IMP, RDVTabBarControllerDelegate>

LC_PROPERTY(strong) TencentOAuth * tencentOAuth;
LC_PROPERTY(assign) NSTimeInterval enterBackgroundTimeInterval;
LC_PROPERTY(strong) NSDictionary *launchOptions;

@end

@implementation AppDelegate

/**
 *  应用程序启动就会调用此方法
 */

- (void)load:(NSDictionary *)launchOptions {
    self.launchOptions = launchOptions;
    
    self.window.rootViewController = [LKNavigator navigator].mainViewController;
    
    // Mob短信验证
    [self setupSMS];
    [self setupNetworkConfig];
    [self setupCache];
    [self setupMAMapServices];
    [self setupSNSConfig];
    [self setupFaultTolerance];
    [self setupDebugger];
    [self setupUmengStatistics];
    [self setupCMD];
    
    if (!LKLocalUser.singleton.isLogin) {
        // 游客模式
        [[LKNavigator navigator] launchGuestMode];
        
    } else {
        
        // 登陆成功
        // 如果是第一次登陆,选择兴趣标签
        BOOL firstStart = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"];
        // 判断是否是初次启动
        if (!firstStart) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
            [[NSUserDefaults standardUserDefaults] synchronize];
//            LKChooseTagView *chooseView = [LKChooseTagView chooseTagView];
//            [UIApplication sharedApplication].keyWindow.ADD(chooseView);

            [self checkAppUpdate];

            LKChooseInterestView *chooseView = [[LKChooseInterestView alloc] initWithFrame:CGRectMake(0, 20, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT)];
            [UIApplication sharedApplication].keyWindow.ADD(chooseView);
        }
        
        [[LKNavigator navigator] launchMasterMode];
        [self setupNotificationObserving];
        [self setupPushService:launchOptions];
    }
}

- (void)setupNetworkConfig {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    LCNetworkConfig *config = [LCNetworkConfig sharedInstance];
    config.baseUrl = @"http://api.likeorz.com";
    LCUrlArgumentsFilter *urlFilter = [LCUrlArgumentsFilter filterWithArguments:@{@"version": appVersion}];
    [config addUrlFilter:urlFilter];
    // 2.设置网络指示器
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

- (void)setupCache {
    // 1.设置缓存
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:cache];
}

- (void)setupMAMapServices {
    [MAMapServices sharedServices].apiKey = @"4c0db296d4f4d092fdaa9004ee8c959a";
}

- (void)setupSNSConfig {
    // 微信
    [WXApi registerApp:@"wxa3f301de2a84df8b"];
    // qq
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1104653828" andDelegate:nil];
    // facebook
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    // 微博
    [WeiboSDK registerApp:@"2142262721"];
}

- (void)setupFaultTolerance {
    // 全局容错
    [LCSwizzle beginFaultTolerant];
}

- (void)setupDebugger {
    // Debugger
    [LCDebugger sharedInstance];
}

- (void)setupUmengStatistics {
    // UMeng
    [MobClick startWithAppkey:@"54bf7949fd98c563bc00075d" reportPolicy:SENDWIFIONLY channelId:@"App Store"];
//    [MobClick checkUpdate];
}

#define kStoreAppId                     @"975648403"  // （appid数字串）

-(void)checkAppUpdate
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *nowVersion = [infoDict objectForKey:@"CFBundleVersion"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", kStoreAppId]];
    NSString * file =  [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    NSRange substr = [file rangeOfString:@"\"version\":\""];
    NSRange range1 = NSMakeRange(substr.location+substr.length,10);
    NSRange substr2 =[file rangeOfString:@"\"" options:nil range:range1];
    NSRange range2 = NSMakeRange(substr.location+substr.length, substr2.location-substr.location-substr.length);
    NSString *newVersion =[file substringWithRange:range2];
    if(![nowVersion isEqualToString:newVersion])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"版本有更新" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新",nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        // 此处加入应用在app store的地址，方便用户去更新，一种实现方式如下：
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", kStoreAppId]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)setupCMD {
    // CMD
    [LCCMD addObjectCMD:@"session" CMDType:LC_CMD_TYPE_SEE IMPObject:self CMDDescription:@"User session."];
    [LCCMD addObjectCMD:@"uid" CMDType:LC_CMD_TYPE_SEE IMPObject:self CMDDescription:@"User id."];
    [LCCMD addObjectCMD:@"refreshtoken" CMDType:LC_CMD_TYPE_SEE IMPObject:self CMDDescription:@"Refresh token."];
}

- (void)setupSMS {
    // Mob短信验证
    [SMSSDK registerApp:@"81edd3d46294" withSecret:@"91a6694191e296937995cd3f66f5e9ca"];
}

- (void)setupPushService:(NSDictionary *)launchOptions {
    // 极光推送
    if (IOS8_OR_LATER) {
        
        // 若系统为iOS 8以后的版本,需要注册通知
        //        UIUserNotificationSettings * settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert) categories:nil];
        //
        //        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        //        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    }
    else{
        
        //        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        //        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
        
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
    
    [APService setupWithOption:launchOptions];
    
    if (LKLocalUser.singleton.isLogin) {
        [APService setTags:nil alias:[NSString stringWithFormat:@"%@", LKLocalUser.singleton.user.id] callbackSelector:@selector(tagsAliasCallback:tags:alias:) target:self];
    }
    
    // Please notify the application each time the orientation is changed.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // 判断是否为推送打开
    if (LKLocalUser.singleton.isLogin && launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
//        [self.homeViewController performSelector:@selector(notificationAction) withObject:nil afterDelay:0.5];
    }
}

- (void)setupNotificationObserving {
    // 会话错误通知
    [self observeNotification:LKSessionError];
    // 应用程序远程登录通知
    [self observeNotification:kJPFNetworkDidRegisterNotification];
    
    // 应用程序远程登录失败通知
    //    [self observeNotification:LCUIApplicationDidRegisterRemoteFailNotification];
    
    // 应用程序接收到远程通知
    //    [self observeNotification:LCUIApplicationDidReceiveRemoteNotification];
    [self observeNotification:kJPFNetworkDidReceiveMessageNotification];
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    
    NSString *callbackString = [NSString stringWithFormat:@"%d, \nalias: %@\n", iResCode, alias];
    NSLog(@"TagsAlias回调:%@", callbackString);
}

/**
 *  禁止屏幕转向
 */
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

/**
 *  获取当前的控制器
 */
- (UIViewController *) getCurrentViewController {
    UIViewController * result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
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
            
            // 判断是否为推送打开
            if ([UIApplication sharedApplication].applicationIconBadgeNumber) {
//                [self.homeViewController performSelector:@selector(notificationAction) withObject:nil afterDelay:0.5];
            }
            
        }
        
        // 检查通知数量
        [LKNotificationCount startCheck];
    }
    
    if (self.enterBackgroundTimeInterval > 60 * 5) {
        
        // 进入后台超过5分钟,发送重新加载数据的通知
//        [self postNotification:LKHomeViewControllerReloadingData];
    }
}

/**
 *  进入后台时间累加1s
 */
- (void)handleTimer:(NSTimer *)timer
{
    self.enterBackgroundTimeInterval += 1.0;
}

#pragma mark - ***** LC_CMD_IMP *****
-(NSString *) CMDSee:(NSString *)cmd {
    
    if ([cmd isEqualToString:@"session"]) {
        return LKLocalUser.singleton.sessionToken;
    } else if ([cmd isEqualToString:@"uid"]) {
        return [NSString stringWithFormat:@"%@",LKLocalUser.singleton.user.id];
    } else if ([cmd isEqualToString:@"refreshtoken"]) {
        return LKLocalUser.singleton.refreshToken;
    }
    return @"";
}

/**
 *  根据通知类型处理对应的操作
 */
- (void)handleNotification:(NSNotification *)notification {
    if ([notification is:LKSessionError]) {
        NSInteger errorCode = [notification.object integerValue];
        if (errorCode == 4016) {
            [LKLocalUser regetSessionTokenAndUseLoadingTip:YES];
        } else if (errorCode == 4013){
            [LKLocalUser logout];
            if (UI_IS_IPHONE4) {
                [LKLoginViewIp4Controller needLoginOnViewController:nil];
            } else {
                [LKLoginViewController needLoginOnViewController:nil];
            }
        }
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
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
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
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [super application:application didReceiveRemoteNotification:userInfo];
    
    // 判断是否是活动状态
    if ( application.applicationState == UIApplicationStateActive ){
    }else{
        // 判断本地用户是否是登录状态
        if (LKLocalUser.singleton.isLogin) {
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    // Bind badge.
    NSInteger badgeCount = [userInfo[@"aps"][@"badge"] integerValue];
    [[LKNavigator navigator] bindBadgeForItemIndex:2 badgeCount:badgeCount];
    
    NSDictionary *alertInfo = userInfo[@"aps"][@"alert"];
    if (alertInfo) {
        
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
}

#pragma mark - ***** 懒加载 *****
- (NSDictionary *)launchOptions {
    if (_launchOptions == nil) {
        _launchOptions = [[NSDictionary alloc] init];
    }
    return _launchOptions;
}

@end
