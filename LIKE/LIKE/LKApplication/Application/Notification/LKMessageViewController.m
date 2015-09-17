//
//  LKMessageViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKMessageViewController.h"

@interface LKMessageViewController ()

@end

@implementation LKMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)buildUI {
    
    self.title = @"通知";
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
