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

@interface LKNotificationViewController () <UITableViewDataSource, UITableViewDelegate, LKPostDetailViewControllerDelegate>

LC_PROPERTY(strong) LKNotificationModel * notificationModel;
LC_PROPERTY(strong) LKNotificationHeader * notificationHeader;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

@end

@implementation LKNotificationViewController

-(void) dealloc {
    [self cancelAllRequests];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.notificationModel = [[LKNotificationModel alloc] init];
    }
    return self;
}

- (void)buildUI {
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.view.viewFrameHeight = self.view.viewFrameHeight - 300;
    
    [self buildNavigationBar];
    
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

- (void)buildNavigationBar {
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
    self.titleView = (UIView *)titleBtn;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
}

-(void)loadData:(LCUIPullLoaderDiretion)diretion
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section != 4) {
        
        return 1;
    }
    
    return self.notificationModel.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        LKNotificationGroupCell *cell = [[LKNotificationGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"like"];
        cell.iconView.image = [UIImage imageNamed:@"NotificationLikeIcon.png" useCache:YES];
        cell.titleLbl.text = @"赞";
        return cell;
    } else if (indexPath.section == 1) {
        
        LKNotificationGroupCell *cell = [[LKNotificationGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"focus"];
        cell.iconView.image = [UIImage imageNamed:@"NotificationFocusIcon.png" useCache:YES];
        cell.titleLbl.text = @"粉丝";
        return cell;
    } else if (indexPath.section == 2) {
        
        LKNotificationGroupCell *cell = [[LKNotificationGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notification"];
        cell.iconView.image = [UIImage imageNamed:@"NotificationCommentIcon.png" useCache:YES];
        cell.titleLbl.text = @"通知";
        return cell;
    } else if (indexPath.section == 3) {
        
        LKNotificationGroupCell *cell = [[LKNotificationGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"group"];
        cell.iconView.image = [UIImage imageNamed:@"NotificationTagIcon.png" useCache:YES];
        cell.titleLbl.text = @"群组";
        return cell;
    } else {
    
        LKNotificationCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Cell" andClass:[LKNotificationCell class]];
        cell.notification = self.notificationModel.datasource[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 4) {
        
        LKNotification * notification = self.notificationModel.datasource[indexPath.row];
        if (notification.posts.count >= 2) {
            
            return 110;
        } else {
            
            return [LKNotificationCell height:notification];
        }
    } else {
        
        return 56;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        LKLikeViewController *likeCtrl = [LKLikeViewController viewController];
        [self.navigationController pushViewController:likeCtrl animated:YES];
        
    } else if (indexPath.section == 1) {
        
        LKFansViewController *fansCtrl = [LKFansViewController viewController];
        [self.navigationController pushViewController:fansCtrl animated:YES];

    } else if (indexPath.section == 2) {

        LKMessageViewController *msgCtrl = [LKMessageViewController viewController];
        [self.navigationController pushViewController:msgCtrl animated:YES];

    } else if (indexPath.section == 3) {
        
        LKGroupViewController *groupCtrl = [LKGroupViewController viewController];
        [self.navigationController pushViewController:groupCtrl animated:YES];

    } else if (indexPath.section == 4) {
    
        LKNotification * notification = self.notificationModel.datasource[indexPath.row];
        if (notification.type == LKNotificationTypeFocus) {
            
            LKUserCenterViewController *userCenterViewController = [[LKUserCenterViewController alloc] initWithUser:notification.user];
            [self.navigationController presentViewController:userCenterViewController animated:YES completion:^{}];
        } else {
            
            if ((notification.type == LKNotificationTypeComment ||
                 notification.type == LKNotificationTypeReply) && [notification.tagID isKindOfClass:[NSNumber class]]) {
                notification.post.tagString = [NSString stringWithFormat:@"Comment-%@",notification.tagID];
            }
            
            [self getOriginPostWithPost:notification.post];
        }
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
            
        } else if (result.state == LKHttpRequestStateFailed) {
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

#pragma mark LKPostDetailViewControllerDelegate
- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didDeletedTag:(LKTag *)deleteTag {
    
}

@end
