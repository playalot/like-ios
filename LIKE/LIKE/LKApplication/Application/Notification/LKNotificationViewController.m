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
#import "LKLoginViewController.h"
#import "LKPostDetailViewController.h"
#import "LKUserCenterViewController.h"
#import "LKNotificationGroupCell.h"
#import "LKLikeViewController.h"
#import "LKFansViewController.h"
#import "LKMessageViewController.h"
#import "LKOfficialDetailViewController.h"
#import "LKOfficialViewController.h"
#import "LRUCache.h"
#import "LKNotificationMiniCell.h"

@interface LKNotificationViewController () <UITableViewDataSource, UITableViewDelegate, LKPostDetailViewControllerDelegate>

LC_PROPERTY(strong) LKNotificationModel *notificationModel;
LC_PROPERTY(strong) LKNotificationHeader *notificationHeader;
LC_PROPERTY(strong) LCUITableView *tableView;
LC_PROPERTY(strong) LCUIPullLoader *pullLoader;
LC_PROPERTY(strong) LCUIImageView *cartoonImageView;

LC_PROPERTY(assign) BOOL isCellPrecomuted;
LC_PROPERTY(strong) NSMutableArray *precomputedCells;
LC_PROPERTY(strong) LRUCache *precomputedCellCache;

@end

@implementation LKNotificationViewController

-(void) dealloc {
    
    [self cancelAllRequests];
}

- (instancetype)init {
    if (self = [super init]) {
        self.notificationModel = [[LKNotificationModel alloc] init];
    }
    return self;
}

- (void)buildCellCache {
    self.isCellPrecomuted = NO;
    self.precomputedCells = [NSMutableArray array];
    self.precomputedCellCache = [[LRUCache alloc] initWithCapacity:10];
}

- (void)buildUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self buildNavigationBar];
    
    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = self.view.bounds;
    self.tableView.viewFrameHeight -= 49;
    self.tableView.backgroundView = nil;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.ADD(self.tableView);
    
    self.cartoonImageView = LCUIImageView.view;
    self.cartoonImageView.viewFrameWidth = 196;
    self.cartoonImageView.viewFrameHeight = 367;
    self.cartoonImageView.viewCenterX = self.tableView.viewCenterX;
    self.cartoonImageView.viewCenterY = self.tableView.viewCenterY;
    self.cartoonImageView.image = [UIImage imageNamed:@"NoFollowing.png" useCache:YES];
    self.cartoonImageView.hidden = YES;
    self.tableView.ADD(self.cartoonImageView);
    
    @weakly(self);
    
    self.pullLoader = [[LCUIPullLoader alloc] initWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeaderAndFooter];
    [self.pullLoader setBeginRefresh:^(LCUIPullLoaderDiretion diretion) {
        @normally(self);
        [self loadData:diretion];
    }];
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

- (void)buildNavigationBar {
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleBtn.title = LC_LO(@"消息提醒");
    titleBtn.titleFont = LK_FONT_B(16);
    self.titleView = (UIView *)titleBtn;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
}

-(void)loadData:(LCUIPullLoaderDiretion)diretion {
    [self.notificationModel cancelAllRequests];
    
    @weakly(self);
    
    [self.notificationModel getNotificationsAtFirstPage:diretion == LCUIPullLoaderDiretionTop requestFinished:^(NSString *error) {
        @normally(self);
        self.cartoonImageView.hidden = self.notificationModel.datasource.count ? YES : NO;
        if (diretion == LCUIPullLoaderDiretionTop) {
            [LKNotificationCount cleanBadge];
        }
        [self.pullLoader endRefresh];
        [self.tableView reloadData];
    }];
}

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal) {
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationModel.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (UI_IS_IPHONE6PLUS) {
        
        LKNotificationCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Cell" andClass:[LKNotificationCell class]];
        cell.notification = self.notificationModel.datasource[indexPath.row];
        return cell;
    } else {
        
        LKNotificationMiniCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Cell" andClass:[LKNotificationMiniCell class]];
        cell.notification = self.notificationModel.datasource[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(LCUITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (UI_IS_IPHONE6PLUS) {
        
        LKNotificationCell *notiCell = (LKNotificationCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return notiCell.cellHeight;
    } else {
        
        LKNotificationMiniCell *notiCell = (LKNotificationMiniCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return notiCell.cellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LKNotification *notification = self.notificationModel.datasource[indexPath.row];
    if (indexPath.row == 0) {
        LKOfficialViewController *officialViewController = [LKOfficialViewController viewController];
        [self.navigationController pushViewController:officialViewController animated:YES];
        return;
    }
    if (notification.type == LKNotificationTypeFocus) {
        [LKUserCenterViewController pushUserCenterWithUser:notification.user navigationController:self.navigationController];
        
    } else {
        
        if ((notification.type == LKNotificationTypeComment ||
            notification.type == LKNotificationTypeReply) && [notification.tagID isKindOfClass:[NSNumber class]]) {
            notification.post.tagString = [NSString stringWithFormat:@"Comment-%@",notification.tagID];
        }
        [self getOriginPostWithPost:notification.post];
    }
}

/**
 *  解决进入图片详情页面图片模糊的问题
 */
- (void)getOriginPostWithPost:(LKPost *)post {
    
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@", post.id]].GET_METHOD();
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        if (result.state == LKHttpRequestStateFinished) {
         
            NSString *content = result.json[@"data"][@"content"];
            post.content = content;
            
            LKPostDetailViewController *detailViewController = [[LKPostDetailViewController alloc] initWithPost:post];
            [self.navigationController presentViewController:detailViewController animated:YES completion:^{}];

//            LKOfficialDetailViewController *detailCtrl = [[LKOfficialDetailViewController alloc] init];
//            [self.navigationController pushViewController:detailCtrl animated:YES];

        } else if (result.state == LKHttpRequestStateFailed) {
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

#pragma mark LKPostDetailViewControllerDelegate
- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didDeletedTag:(LKTag *)deleteTag {
    
}

@end
