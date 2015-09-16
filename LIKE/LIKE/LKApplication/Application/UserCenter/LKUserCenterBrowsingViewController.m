//
//  LKUserCenterBrowsingViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserCenterBrowsingViewController.h"

@interface LKUserCenterBrowsingViewController ()

LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

@end

@implementation LKUserCenterBrowsingViewController

- (void)reloadData {
    [self.pullLoader endRefresh];
    [self.tableView reloadData];
}

- (void)buildUI {
    [super buildUI];
    
    [self setNavigationBarHidden:NO animated:NO];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeaderAndFooter];
    @weakly(self);
    self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion) {
        @normally(self);
        [self loadData:diretion];
    };
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

// 这个方法同时负责主页和关注的人列表的请求
- (void)loadData:(LCUIPullLoaderDiretion)diretion {
//    [self.parentUserCenterViewController updateUserMetaInfo];
//    [self.parentUserCenterViewController loadData:LKUserCenterModelTypePhotos diretion:LCUIPullLoaderDiretionTop];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [super setCurrentIndex:currentIndex];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

@end
