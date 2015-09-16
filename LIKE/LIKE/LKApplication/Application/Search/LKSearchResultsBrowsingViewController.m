//
//  LKSearchResultsBrowsingViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/16/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchResultsBrowsingViewController.h"

@interface LKSearchResultsBrowsingViewController ()

LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

@end

@implementation LKSearchResultsBrowsingViewController

- (void)reloadData {
    [self.pullLoader endRefresh];
    [self.tableView reloadData];
}

- (void)buildUI {
    [super buildUI];
    
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
    [self.parentSearchResultsViewController loadData:diretion];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [super setCurrentIndex:currentIndex];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    [super handleNavigationBarButton:type];
    NSIndexPath *visibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
    [self.parentSearchResultsViewController scrollToPostByIndex:visibleIndexPath.row];
}

@end
