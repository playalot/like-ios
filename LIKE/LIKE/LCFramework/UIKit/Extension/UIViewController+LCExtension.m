//
//  UIViewController+LCExtension.m
//  LCFrameworkDemo
//
//  Created by 王振君 on 15-4-9.
//  Copyright (c) 2015年 Licheng Guo . http://nsobject.me/. All rights reserved.
//

#import "UIViewController+LCExtension.h"

@implementation UIViewController (LCExtension)

-(void) dismissOrPopViewController {
    if (![self.navigationController popViewControllerAnimated:YES]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
