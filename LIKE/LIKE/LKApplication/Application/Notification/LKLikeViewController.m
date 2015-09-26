//
//  LKLikeViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLikeViewController.h"
#import "LKNotificationModel.h"
#import "LKNotificationCell.h"
#import "LKPostDetailViewController.h"

@interface LKLikeViewController ()

LC_PROPERTY(strong) LKNotificationModel *notificationModel;

@end

@implementation LKLikeViewController

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

    self.title = LC_LO(@"赞");
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
        
    }];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ***** tableView dataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.notificationModel.likesArray.count;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LKNotificationCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Cell" andClass:[LKNotificationCell class]];
    cell.notification = self.notificationModel.likesArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LKNotification *notification = self.notificationModel.likesArray[indexPath.row];
    
    [self getOriginPostWithPost:notification.post];
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

@end
