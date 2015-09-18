//
//  LKFansViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFansViewController.h"
#import "LKNotificationModel.h"
#import "LKNotificationCell.h"
#import "LKPostDetailViewController.h"

@interface LKFansViewController ()

LC_PROPERTY(strong) LKNotificationModel *notificationModel;

@end

@implementation LKFansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.notificationModel = [[LKNotificationModel alloc] init];
    }
    return self;
}

- (void)buildUI {
    
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.title = LC_LO(@"粉丝");
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    
    @weakly(self);
    
    self.pullLoader = [[LCUIPullLoader alloc] initWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeaderAndFooter];
    
    [self.pullLoader setBeginRefresh:^(LCUIPullLoaderDiretion diretion) {
        @normally(self);
        
        [self loadData:diretion];
    }];
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

-(void)loadData:(LCUIPullLoaderDiretion)diretion {
    
    [self.notificationModel cancelAllRequests];
    
    @weakly(self);
    
    [self.notificationModel getNotificationsAtFirstPage:diretion == LCUIPullLoaderDiretionTop requestFinished:^(NSString *error) {
        
        @normally(self);
        
        [self.pullLoader endRefresh];
        [self.tableView reloadData];
        
    } type:LKNotificationModelTypeFollow];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ***** tableView dataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.notificationModel.followsArray.count;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LKNotificationCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Cell" andClass:[LKNotificationCell class]];
    cell.notification = self.notificationModel.followsArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LKNotification *notification = self.notificationModel.followsArray[indexPath.row];
    
    if (notification.posts.count >= 2) {
        
        return 110;
    } else {
        
        return [LKNotificationCell height:notification];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LKNotification *notification = self.notificationModel.followsArray[indexPath.row];

    LKUserCenterViewController *userCenterViewController = [[LKUserCenterViewController alloc] initWithUser:notification.user];
    [self.navigationController presentViewController:userCenterViewController animated:YES completion:nil];
}

@end
