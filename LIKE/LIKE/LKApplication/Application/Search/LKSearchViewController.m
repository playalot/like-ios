//
//  LKSearchViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/13/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchViewController.h"

@interface LKSearchViewController ()

@end

@implementation LKSearchViewController

+ (id)sharedInstance {
    static LKSearchViewController *instance_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[LKSearchViewController alloc] init];
    });
    return instance_;
}

- (void)buildUI {
    self.view.backgroundColor = [LKColor backgroundColor];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
