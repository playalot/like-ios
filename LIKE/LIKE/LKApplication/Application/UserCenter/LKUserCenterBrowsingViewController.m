//
//  LKUserCenterBrowsingViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/6/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserCenterBrowsingViewController.h"

@interface LKUserCenterBrowsingViewController () <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

LC_PROPERTY(strong) NSMutableArray * datasource;

LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

@end

@implementation LKUserCenterBrowsingViewController

-(void) dealloc
{
    [self cancelAllRequests];
    [self unobserveAllNotifications];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) buildUI
{
    self.view.backgroundColor = LKColor.backgroundColor;
}

#pragma mark - ***** 数据源方法 *****

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NULL;
}

/**
 *  根据cell计算行高
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 38;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

@end
