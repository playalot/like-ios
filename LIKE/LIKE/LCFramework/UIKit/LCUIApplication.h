//
//  LC_UIApplicationSkeleton.h
//  LCFramework
//
//  Created by Licheng Guo . ( SUGGESTIONS & BUG titm@tom.com ) on 13-10-11.
//  Copyright (c) 2014年 Licheng Guo iOS developer ( http://nsobject.me ).All rights reserved.
//  Also see the copyright page ( http://nsobject.me/copyright.rtf ).
//
//

#import <UIKit/UIKit.h>


LC_NOTIFICATION_SET(LCUIApplicationDidRegisterRemoteNotification);
LC_NOTIFICATION_SET(LCUIApplicationDidRegisterRemoteFailNotification);
LC_NOTIFICATION_SET(LCUIApplicationDidReceiveRemoteNotification);
LC_NOTIFICATION_SET(LCUIApplicationDidReceiveLocalNotification);


@interface LCUIApplication : UIResponder <UIApplicationDelegate>

LC_PROPERTY(strong) UIWindow * window;

+ (LCUIApplication *) sharedInstance;

- (void) load:(NSDictionary *)launchOptions;

+(void) presentViewController:(UIViewController *)viewController;
+(void) presentViewController:(UIViewController *)viewController animation:(BOOL)animation;
-(void) presentViewController:(UIViewController *)viewController animation:(BOOL)animation;

@end
