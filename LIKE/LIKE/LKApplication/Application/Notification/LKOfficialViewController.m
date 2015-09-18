//
//  LKOfficialViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKOfficialViewController.h"
#import "LKNormalOfficialCell.h"
#import "LKNotificationOfficialCell.h"
#import "LKOfficialDetailViewController.h"

@interface LKOfficialViewController ()

@end

@implementation LKOfficialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = LKColor.backgroundColor;
}

#pragma mark - ***** tableView dataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        LKNormalOfficialCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"NormalCell" andClass:[LKNormalOfficialCell class]];
        return cell;
    } else {
        
        LKNotificationOfficialCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"LargeCell" andClass:[LKNotificationOfficialCell class]];
        return cell;
    }
}

- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        return 100;
    } else {
        
        return 200;
    }
}

#pragma mark - ***** tableView delegate *****
- (void)tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LKOfficialDetailViewController *detailCtrl = [[LKOfficialDetailViewController alloc] init];
    [self presentViewController:detailCtrl animated:YES completion:nil];
}

@end
