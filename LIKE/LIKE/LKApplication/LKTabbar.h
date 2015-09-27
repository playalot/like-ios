//
//  LKTabbar.h
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/26.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LKTabBarDelegate;

@interface LKTabbar : UITabBar

@property (nonatomic, weak) id <LKTabBarDelegate> delegate;

@end

@protocol LKTabBarDelegate <NSObject, UITabBarDelegate>
/**
 *  点击了plusBtn就会调用这个代理方法
 */
- (void)tabBar:(LKTabbar *)tabBar didClickCameraButton:(LCUIButton *)cameraButton;

@end
