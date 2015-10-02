//
//  LKTabbarController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/26.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTabbarViewController.h"
#import "LKTabbar.h"
#import "LKTabbarItem.h"
#import "LKCameraRollViewController.h"
#import "LKMainFeedViewController.h"
#import "LKSearchViewController.h"
#import "LKNotificationViewController.h"
#import "LKUserCenterViewController.h"

@interface LKTabbarViewController () <LKTabBarDelegate>

@end

@implementation LKTabbarViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化自定义tabBar
    LKTabbar *tabBar = [[LKTabbar alloc] init];
    // 设置代理
    tabBar.delegate = self;
    // 由于self.tabBar的属性是readOnly,所以要使用KVC进行设置
    [self setValue:tabBar forKeyPath:@"tabBar"];
    
    NSArray *imageNameArray = @[@"tabbar_homeLine",
                                @"tabbar_search",
                                @"tabbar_notification",
                                @"tabbar_userCenter"];
    
    // 添加控制器
    LKMainFeedViewController *mainCtrl = [LKMainFeedViewController viewController];
    [self addChildViewController:mainCtrl withImageName:imageNameArray[0]];

    LKSearchViewController *searchCtrl = [LKSearchViewController viewController];
    [self addChildViewController:searchCtrl withImageName:imageNameArray[1]];
    
    LKNotificationViewController *notificationCtrl = [LKNotificationViewController viewController];
    [self addChildViewController:notificationCtrl withImageName:imageNameArray[2]];
    
    LKUserCenterViewController *userCenterCtrl = [[LKUserCenterViewController alloc] initWithUser:LKLocalUser.singleton.user];
    [self addChildViewController:userCenterCtrl withImageName:imageNameArray[3]];
}

/**
 *  每创建一个控制器,就要调用一次添加控制器的方法
 *
 *  @param controller tabBarController的子控制器
 *  @param title      子控制器tabBarItem的title
 *  @param imageName  子控制器tabBarItem的imageName
 */
- (void)addChildViewController:(UIViewController *)controller withImageName:(NSString *)imageName {
    
#warning 把系统的 tabBarItem 改为 自定义的 tabBarItem
    LKTabbarItem *tabBarItem = [[LKTabbarItem alloc] init];
    controller.tabBarItem = tabBarItem;
    
    controller.tabBarItem.image = [UIImage imageNamed:imageName];
    
    // 拼接选中状态的图片字符串
    NSString *selectedImageName = [NSString stringWithFormat:@"%@_selected", imageName];
    controller.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 给每一个控制器都嵌入一个导航控制器
    // 添加到tabBarController中
    [self addChildViewController:LC_UINAVIGATION(controller)];
}

#pragma mark - LKTabBarDelegate
- (void)tabBar:(LKTabbar *)tabBar didClickCameraButton:(LCUIButton *)cameraButton {
    
    LKCameraRollViewController *composeCtrl = [LKCameraRollViewController viewController];
    [self presentViewController:LC_UINAVIGATION(composeCtrl) animated:YES completion:nil];
}

@end
