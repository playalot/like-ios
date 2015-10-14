//
//  LKNavigator.m
//  LIKE
//
//  Created by huangweifeng on 9/27/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNavigator.h"
#import "LKLoginViewController.h"
#import "LKWelcome.h"
#import "LKGuestFeedViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "LKNotificationCount.h"
#import "LKGateViewController.h"
#import "LKUserProfileViewController.h"

@interface LKNavigator () <LKLoginViewControllerDelegate, RDVTabBarControllerDelegate>

LC_PROPERTY(strong) LKLoginViewController *loginViewController;
LC_PROPERTY(strong) LKGuestFeedViewController *guestFeedViewController;
LC_PROPERTY(strong) LKGateViewController *gateViewController;

@end

@implementation LKNavigator

+ (instancetype)navigator {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LKNavigator alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mainViewController = [[LCUINavigationController alloc] init];
        self.mainViewController.navigationBarHidden = YES;
    }
    return self;
}

- (void)popToRootViewController:(BOOL)animated {
    [self.mainViewController popToRootViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.mainViewController pushViewController:viewController animated:animated];
}

- (void)popViewController:(BOOL)animated {
    [self.mainViewController popViewControllerAnimated:animated];
}

- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)flag {
    [self.mainViewController popToViewController:viewController animated:flag];
}

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)flag completion:(void (^ __nullable)(void))completion {
    [self.mainViewController presentViewController:viewController animated:YES completion:completion];
}

- (void)openLoginViewController {
    [self.mainViewController presentViewController:self.loginViewController animated:NO completion:^{}];
}

- (LKLoginViewController *)loginViewController {
    if (_loginViewController == nil) {
        _loginViewController = LKLoginViewController.viewController;
        _loginViewController.delegate = self;
    }
    return _loginViewController;
}

- (LKGateViewController *)gateViewController {
    if (!_gateViewController) {
        _gateViewController = [LKGateViewController viewController];
    }
    return _gateViewController;
}

- (void)launchGuestMode {
    self.mainViewController.viewControllers = @[];
    self.guestFeedViewController = [LKGuestFeedViewController viewController];
    [self.mainViewController pushViewController:self.guestFeedViewController animated:NO];
    
    BOOL hasOnceLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasOnceLogin"];
    if (!hasOnceLogin) {
        [self.mainViewController pushViewController:self.loginViewController animated:NO];
        [self.mainViewController pushViewController:self.gateViewController animated:NO];
    } else {
        [self openLoginViewController];
    }
}

- (void)launchMasterMode {
    self.mainViewController.viewControllers = @[];
    [self setupViewControllers];
    [[LKNavigator navigator] pushViewController:self.tabBarController animated:NO];
}

- (void)dismissAllViewControllers {
    [self.loginViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)bindBadgeForItemIndex:(NSInteger)index badgeCount:(NSInteger)badgeCount {
    if (badgeCount > 0) {
        RDVTabBarItem *item = self.tabBarController.tabBar.items[index];
        [item setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_notification_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_notification_badge.png"]];
        [item setNeedsDisplay];
        [LKNotificationCount bindView:item withBadgeCount:badgeCount];
    }
}

- (void)setupViewControllers {
    self.mainFeedViewController = [LKMainFeedViewController viewController];
    self.searchViewController = [LKSearchViewController viewController];
    self.cameraRollViewController = [LKCameraRollViewController viewController];
    self.notificationViewController = [LKNotificationViewController viewController];
    self.userProfileViewController = [[LKUserProfileViewController alloc] initWithUser:LKLocalUser.singleton.user];
    
    // tabbarCtrl只放了一个主页控制器
    self.tabBarController = [[LKTabBarController alloc]
                             initWithViewControllers:@[
                                                       LC_UINAVIGATION(self.mainFeedViewController),
                                                       LC_UINAVIGATION(self.searchViewController),
                                                       LC_UINAVIGATION(self.notificationViewController),
                                                       LC_UINAVIGATION(self.userProfileViewController)]];
    self.tabBarController.delegate = self;
    
    NSString *cache =  LKUserDefaults.singleton[self.class.description];
    NSArray *imageNames = @[@"tabbar_homeLine",
                            @"tabbar_search",
                            cache != nil ? @"tabbar_notification_badge" : @"tabbar_notification",
                            @"tabbar_userCenter"];
    
    NSArray *selectedImageNames = @[@"tabbar_homeLine_selected",
                                    @"tabbar_search_selected",
                                    @"tabbar_notification_selected",
                                    @"tabbar_userCenter_selected"];
    
    
    NSInteger i = 0;
    for (UIView *view in self.tabBarController.tabBar.items) {
        if ([view isKindOfClass:[RDVTabBarItem class]]) {
            RDVTabBarItem *item = (RDVTabBarItem *)view;
            [item setFinishedSelectedImage:[[UIImage imageNamed:selectedImageNames[i]]
                                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
               withFinishedUnselectedImage:[[UIImage imageNamed:imageNames[i]]
                                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [item setBackgroundColor:[UIColor whiteColor]];
            i++;
        }
    }
    
    [LKNotificationCount startCheck];
    LKNotificationCount.singleton.requestFinished = ^(NSUInteger count) {
        
        RDVTabBarItem *item = self.tabBarController.tabBar.items[2];
        
        if (count) {
            NSLog(@"%@", item);
            [item setFinishedSelectedImage:[[UIImage imageNamed:@"tabbar_notification_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[[UIImage imageNamed:@"tabbar_notification_badge"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [item setNeedsDisplay];
        } else {
            [item setFinishedSelectedImage:[[UIImage imageNamed:@"tabbar_notification_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] withFinishedUnselectedImage:[[UIImage imageNamed:@"tabbar_notification"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [item setNeedsDisplay];
        }
    };
}

#pragma mark - ***** RDVTabBarControllerDelegate *****
- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if (viewController.childViewControllers[0] == self.notificationViewController) {
        [LKNotificationCount cleanBadge];
        [LKNotificationCount stopCheck];
    } else {
        [LKNotificationCount startCheck];
    }
    return YES;
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectCurrentViewController:(UIViewController *)viewController {
    if (viewController == self.mainFeedViewController.navigationController) {
        [self.mainFeedViewController refresh];
    } else if (viewController == self.searchViewController.navigationController) {
        [self.searchViewController refresh];
    } else if (viewController == self.notificationViewController.navigationController) {
        [self.notificationViewController refresh];
    } else if (viewController == self.userProfileViewController.navigationController) {
        [self.userProfileViewController refresh];
    }
}

#pragma mark LKLoginViewControllerDelegate
- (void)didLoginSucceeded:(NSDictionary *)userInfo {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasOnceLogin"];
    [self launchMasterMode];
}

- (void)didLoginFailed {
    [self showTopMessageErrorHud:LC_LO(@"登录失败")];
}

@end
