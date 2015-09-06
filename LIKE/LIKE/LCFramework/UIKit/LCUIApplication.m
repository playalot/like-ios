//
//  LC_UIApplicationSkeleton.m
//  LCFramework

//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-11.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import "LCUIApplication.h"
#import "APService.h"
#import "LKNotificationViewController.h"
#import "LKHomeViewController.h"
#import "LCNetworkConfig.h"
#import "LCUrlArgumentsFilter.h"

static LCUIApplication * __skeleton = nil;

@implementation LCUIApplication

+ (LCUIApplication *)sharedInstance {
    return __skeleton;
}

- (void) configNetwork {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    LCNetworkConfig *config = [LCNetworkConfig sharedInstance];
    config.baseUrl = LK_API_BASE_URL;
    LCUrlArgumentsFilter *urlFilter = [LCUrlArgumentsFilter filterWithArguments:@{@"version": appVersion}];
    [config addUrlFilter:urlFilter];
}

- (void) load:(NSDictionary *)launchOptions {
}

+(void) presentViewController:(UIViewController *)viewController
{
    [[LCUIApplication sharedInstance] presentViewController:viewController animation:NO];
}

+(void) presentViewController:(UIViewController *)viewController animation:(BOOL)animation
{
    [[LCUIApplication sharedInstance] presentViewController:viewController animation:animation];
}

-(void) presentViewController:(UIViewController *)viewController animation:(BOOL)animation
{
    if(self.window.rootViewController.presentedViewController){
        
        [self.window.rootViewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
            
            [self.window.rootViewController presentViewController:viewController animated:animation completion:nil];
        }];
    }
    else{
        
        [self.window.rootViewController presentViewController:viewController animated:animation completion:nil];
    }
}

#pragma mark -

- (void)initializeWindow
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	INFO( @"[LCUIApplication] Did finish launching." );
	[self application:application didFinishLaunchingWithOptions:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	__skeleton = self;
    
    [self configNetwork];
	[self initializeWindow];
    [self load:launchOptions];
	
	if (self.window.rootViewController){
        UIView * rootView = self.window.rootViewController.view;
		if (rootView){
			[self.window makeKeyAndVisible];
		}
	}
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
}

#pragma mark -

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	INFO( @"[LCUIApplication] Application did become active." );
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	INFO( @"[LCUIApplication] Application will resign active." );
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	INFO( @"[LCUIApplication] Application did receive memory warning." );
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	INFO( @"[LCUIApplication] Application will terminate." );
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	INFO( @"[ Application did enter background. ]" );
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	INFO( @"[ Application will enter foreground. ]" );
}

#pragma mark -

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
{
	
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
{
	
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
	
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
	
}

#pragma mark -


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//	NSString * token = [deviceToken description];
//	token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
//	token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
//	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
//    [self postNotification:LCUIApplicationDidRegisterRemoteNotification withObject:token];
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    [self postNotification:LCUIApplicationDidRegisterRemoteFailNotification withObject:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//	UIApplicationState state = [UIApplication sharedApplication].applicationState;
//	if ( UIApplicationStateInactive == state || UIApplicationStateBackground == state )
//	{
//		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo, @"userInfo", [NSNumber numberWithBool:NO], @"inApp", nil];
//        [self postNotification:LCUIApplicationDidReceiveRemoteNotification withObject:dict];
        
//	}
//	else
//	{
//		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo, @"userInfo", [NSNumber numberWithBool:YES], @"inApp", nil];
//        [self postNotification:LCUIApplicationDidReceiveRemoteNotification withObject:dict];
        
//	}
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	UIApplicationState state = [UIApplication sharedApplication].applicationState;
	if ( UIApplicationStateInactive == state || UIApplicationStateBackground == state )
	{
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:notification.userInfo, @"userInfo", [NSNumber numberWithBool:NO], @"inApp", nil];
        [self postNotification:LCUIApplicationDidReceiveLocalNotification withObject:dict];
	}
	else
	{
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:notification.userInfo, @"userInfo", [NSNumber numberWithBool:YES], @"inApp", nil];
        [self postNotification:LCUIApplicationDidReceiveLocalNotification withObject:dict];
	}
}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application
{
    
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
    
}


@end
