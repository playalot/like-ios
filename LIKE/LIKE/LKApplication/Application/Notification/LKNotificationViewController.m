//
//  LKNotificationViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/14/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationViewController.h"
#import "LKNotificationModel.h"
#import "LKNotificationCount.h"
#import "LKNotificationCell.h"
#import "LKNotificationHeader.h"

@interface LKNotificationViewController () <UITableViewDataSource,UITableViewDelegate>

LC_PROPERTY(strong) LKNotificationModel * notificationModel;
LC_PROPERTY(strong) LKNotificationHeader * notificationHeader;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

@end

@implementation LKNotificationViewController

-(void) dealloc {
    [self cancelAllRequests];
}

- (void)buildUI {
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.notificationHeader = [[LKNotificationHeader alloc] initWithCGSize:CGSizeMake(LC_DEVICE_WIDTH, 150)];
    self.view.ADD(self.notificationHeader);
    
    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = self.view.bounds;
    self.tableView.backgroundView = nil;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.ADD(self.tableView);
    
    @weakly(self);
    
    self.pullLoader = [[LCUIPullLoader alloc] initWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeaderAndFooter];
    
    [self.pullLoader setBeginRefresh:^(LCUIPullLoaderDiretion diretion) {
        
        @normally(self);
        
        [self loadData:diretion];
        
    }];
    
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

-(void) loadData:(LCUIPullLoaderDiretion)diretion
{
    [self.notificationModel cancelAllRequests];
    
    @weakly(self);
    
    [self.notificationModel getNotificationsAtFirstPage:diretion == LCUIPullLoaderDiretionTop requestFinished:^(NSString *error) {
        
        @normally(self);
        
        if (diretion == LCUIPullLoaderDiretionTop) {
            
            [LKNotificationCount cleanBadge];
        }
        
        [self.pullLoader endRefresh];
        [self.tableView reloadData];
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.notificationModel.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LKNotificationCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Cell" andClass:[LKNotificationCell class]];
    
    cell.notification = self.notificationModel.datasource[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LKNotification * notification = self.notificationModel.datasource[indexPath.row];
    
    if (notification.posts.count >= 2) {
        
        return 110;
    }
    else{
        
        return [LKNotificationCell height:notification];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LKNotification * notification = self.notificationModel.datasource[indexPath.row];
    
    if (notification.type == LKNotificationTypeFocus) {
        
        self.SEND(@"PushUserCenter").object = notification.user;
    }
    else{
        
        
        if ((notification.type == LKNotificationTypeComment ||
             notification.type == LKNotificationTypeReply) && [notification.tagID isKindOfClass:[NSNumber class]]) {
            
            notification.post.tagString = [NSString stringWithFormat:@"Comment-%@",notification.tagID];
        }
        
        self.SEND(@"PushPostDetail").object = notification.post;
    }
}

@end
