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
#import "LKTabbarItem.h"

@interface LKNavigator () <LKLoginViewControllerDelegate, RDVTabBarControllerDelegate>

LC_PROPERTY(strong) LKLoginViewController *loginViewController;
LC_PROPERTY(strong) LKGuestFeedViewController *guestFeedNavViewController; // LKGuestFeedViewController

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
    [self dismissAllViewControllers];
    
    LCUIImageView * imageView = LCUIImageView.view;
    imageView.image = [LKWelcome image];
    imageView.viewFrameWidth = LC_DEVICE_WIDTH;
    imageView.viewFrameHeight = LC_DEVICE_HEIGHT + 20;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [LC_KEYWINDOW addSubview:imageView];
    self.loginViewController = LKLoginViewController.viewController;
    self.loginViewController.delegate = self;
    
    [self.mainViewController presentViewController:self.loginViewController animated:NO completion:^{
        [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            
        }];
    }];
}

- (void)launchGuestMode {
    [self.mainViewController popToRootViewControllerAnimated:NO];
    self.guestFeedNavViewController = [LKGuestFeedViewController viewController];
    [self.mainViewController pushViewController:self.guestFeedNavViewController animated:NO];
    [self openLoginViewController];
}

- (void)launchMasterMode {
    [self.mainViewController popToRootViewControllerAnimated:NO];
    [self setupViewControllers];
//    self.tabBarViewController = [LKTabbarViewController viewController];
    [[LKNavigator navigator] pushViewController:self.tabBarController animated:NO];
}

- (void)dismissAllViewControllers {
    [self.loginViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)bindBadgeForItemIndex:(NSInteger)index badgeCount:(NSInteger)badgeCount {
    if (badgeCount > 0) {
        RDVTabBarItem *item = self.tabBarController.tabBar.items[index];
        [item setBackgroundSelectedImage:[UIImage imageNamed:@"tabbar_notification_selected.png"]
                     withUnselectedImage:[UIImage imageNamed:@"tabbar_notification_badge.png"]];
        [LKNotificationCount bindView:item withBadgeCount:badgeCount];
    }
}

- (void)setupViewControllers {
    self.mainFeedViewController = [LKMainFeedViewController viewController];
    self.searchViewController = [LKSearchViewController viewController];
    self.cameraRollViewController = [LKCameraRollViewController viewController];
    self.notificationViewController = [LKNotificationViewController viewController];
    self.userCenterViewController = [[LKUserCenterViewController alloc] initWithUser:LKLocalUser.singleton.user];
    
    // tabbarCtrl只放了一个主页控制器
    self.tabBarController = [[LKTabBarController alloc]
                             initWithViewControllers:@[
                                                       LC_UINAVIGATION(self.mainFeedViewController),
                                                       LC_UINAVIGATION(self.searchViewController),
//                                                       LC_UINAVIGATION(self.cameraRollViewController),
                                                       LC_UINAVIGATION(self.notificationViewController),
                                                       LC_UINAVIGATION(self.userCenterViewController)]];
    self.tabBarController.delegate = self;
    
    NSArray *imageNames = @[@"tabbar_homeLine",
                            @"tabbar_search",
//                            @"tabbar_camera",
                            @"tabbar_notification",
                            @"tabbar_userCenter"];
    
    NSArray *selectedImageNames = @[@"tabbar_homeLine_selected",
                                    @"tabbar_search_selected",
//                                    @"tabbar_camera",
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
            if (i == 3) {
                LCUIBadgeView *badgeView = LCUIBadgeView.view;
                badgeView.frame = CGRectMake(40 * LC_DEVICE_WIDTH / 414, 13, 2, 2);
                item.ADD(badgeView);
            }
            i++;
        }
    }
}

#pragma mark - ***** RDVTabBarControllerDelegate *****
- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == self.mainFeedViewController) {
        [self.mainFeedViewController refresh];
    }
    return YES;
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

#pragma mark LKLoginViewControllerDelegate
- (void)didLoginSucceeded:(NSDictionary *)userInfo {
    [self launchMasterMode];
}

- (void)didLoginFailed {
}

@end
