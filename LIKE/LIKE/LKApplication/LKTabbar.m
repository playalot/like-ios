//
//  LKTabbar.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/26.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTabbar.h"

@interface LKTabbar ()

LC_PROPERTY(weak) LCUIButton *cameraButton;

@end

@implementation LKTabbar
//@dynamic 修饰的属性代表已经实现了get与set方法    (dynamic: 动态的)
@dynamic delegate;

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.barTintColor = [UIColor whiteColor];
        
        // 初始化中间 plus 按钮
        LCUIButton *cameraButton = LCUIButton.view;
        self.cameraButton = cameraButton;
        
        // 设置 cameraButton 的属性
        [cameraButton setImage:[UIImage imageNamed:@"tabbar_camera.png"]
                 forState:UIControlStateNormal];
        
        // 添加单击事件
        [cameraButton addTarget:self action:@selector(cameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 添加到视图中
        [self addSubview:cameraButton];
    }
    
    return self;
}

/**
 *  布局子控件的时候调用,在这里设置cameraButton的frame
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置button的frame
    self.cameraButton.viewSize = CGSizeMake(82, 49);
    self.cameraButton.viewCenterX = self.viewCenterX;
    self.cameraButton.viewCenterY = self.viewFrameHeight * 0.5;
    
    // UITabBarButton的索引
    NSInteger btnIndex = 0;
    // 计算tabBarButton的宽度
    CGFloat tabBarButtonW = self.viewFrameWidth / 5;
    
    // 重新设置tabBarItem的frame
    for (int i = 0; i < self.subviews.count; i++) {
        
        UIView *childView = self.subviews[i];
        //        EZLog(@"%@", childView);
        
        // 判断是否是UITabBarButton
        if ([childView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            
            // 从第三个开始,重新计算index
            if (btnIndex == 2) {
                btnIndex++;
            }
            
            // 重新计算UITabBarButton的宽度
            childView.viewFrameWidth = tabBarButtonW;
            // 调整位置
            childView.viewFrameX = btnIndex * tabBarButtonW;
            childView.viewFrameY += 5;
            
            btnIndex++;
        }
    }
}

#pragma mark - cameraButton的单击事件
- (void)cameraButtonClick:(LCUIButton *)cameraButton {
    
    if ([self.delegate respondsToSelector:@selector(tabBar:didClickCameraButton:)]) {
        [self.delegate tabBar:self didClickCameraButton:cameraButton];
    }
}

@end
