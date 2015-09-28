//
//  LKProfileSettingViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/28.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKProfileSettingViewController.h"

@interface LKProfileSettingViewController ()

@end

@implementation LKProfileSettingViewController

#pragma mark - ***** TableView DataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

#pragma mark - ***** TableView Delegate *****
- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 55;
}

@end
