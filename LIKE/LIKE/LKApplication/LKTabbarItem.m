//
//  LKTabbarItem.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/26.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTabbarItem.h"
#import "LKTabbar.h"
#import <objc/runtime.h>

@interface LKTabbarItem ()

@property (nonatomic, strong) UIImage *badgeImage;

@end

@implementation LKTabbarItem
/**
 *  为了改变tabBarItem的显示样式(背景颜色),所以需要自定义tabBarItem
 */
- (void)setBadgeValue:(NSString * __nullable)badgeValue {
    
    [super setBadgeValue:badgeValue];
    
    // 由于 _target 是 tabBarItem 的私有属性,所以利用 KVC 来获取UITabBarController
    UITabBarController *tabBarCtrl = [self valueForKeyPath:@"_target"];
    //    LKLog(@"%@", [tabBarCtrl class]);
    
    // 获取自定义tabBar
    LKTabbar *tabBar = (LKTabbar *)tabBarCtrl.tabBar;
    
    // 遍历tabBar里面的所有子控件
    for (UIView *tabBarChildView in tabBar.subviews) {
        
        if ([tabBarChildView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            
            for (UIView *tabBarButtonChildView in tabBarChildView.subviews) {
                
                if ([tabBarButtonChildView isKindOfClass:NSClassFromString(@"_UIBadgeView")]) {
                    
                    for (UIView *backgroundView in tabBarButtonChildView.subviews) {
                        
                        if ([backgroundView isKindOfClass:NSClassFromString(@"_UIBadgeBackground")]) {
                            
                            // 利用运行时遍历类的所有属性
                            Class clazz = [backgroundView class];
                            unsigned int outCount;
                            
                            // 获取属性列表
                            Ivar *ivars = class_copyIvarList(clazz, &outCount);
                            
                            // 遍历属性列表
                            for (int i = 0; i < outCount; i++) {
                                
                                Ivar ivar = ivars[i];
                                
                                // 获取属性的名称
                                const char *ivarName = ivar_getName(ivar);
                                // 获取属性的类型
                                //                                const char *ivarType = ivar_getTypeEncoding(ivar);
                                
                                // 转换为 OC 字符串类型
                                NSString *propertyName = [NSString stringWithUTF8String:ivarName];
                                //                                NSString *propertyType = [NSString stringWithUTF8String:ivarType];
                                
                                //                                LKLog(@"%@  %@", propertyName, propertyType);
                                
                                // 根据属性名称判断是否是需要获取的属性
                                if ([propertyName isEqualToString:@"_image"]) {
                                    
                                    UIImage *badgeImage = [UIImage imageNamed:@"main_badge"];
                                    
                                    // 利用 运行时 或者 KVC 设置属性
                                    object_setIvar(backgroundView, ivar, badgeImage);
                                    //                                    [backgroundView setValue:badgeImage forKeyPath:@"_image"];
                                }
                            }
                            
                            // 使用完要释放
                            free(ivars);
                        }
                    }
                }
            }
        }
    }
}

@end
