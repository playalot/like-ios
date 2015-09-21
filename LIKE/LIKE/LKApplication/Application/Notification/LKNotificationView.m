//
//  LKNotificationView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKNotificationView.h"
#import "LKNotificationModel.h"
#import "LKNotificationCell.h"
#import "LKPostDetailViewController.h"
#import "LKNotificationCount.h"
#import "LKUserCenterViewController.h"
#import "AppDelegate.h"
#import "FXBlurView.h"
#import "LKAssistiveTouchButton.h"

@interface LKNotificationView () <UITableViewDataSource,UITableViewDelegate>

LC_PROPERTY(strong) LKNotificationModel * notificationModel;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) UIView * blur;

@end

@implementation LKNotificationView

-(void) dealloc
{
    [self cancelAllRequests];
}

//-(void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
//
//    [self setNavigationBarHidden:NO animated:animated];
//    
//
//}


//-(void) viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    ((LCUINavigationController *)self.navigationController).animationHandler = nil;
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    ((LCUINavigationController *)self.navigationController).animationHandler = ^id(UINavigationControllerOperation operation, UIViewController * fromVC, UIViewController * toVC){
//        
//        if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[LKPostDetailViewController class]]) {
//            return [[LKPushAnimation alloc] init];
//        }
//        
//        return nil;
//    };
//}

-(instancetype) init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 64)]) {
        
        self.notificationModel = [[LKNotificationModel alloc] init];
        
        [LKNotificationCount stopCheck];
        
        [self buildUI];
        
        // 刷新页面,避免删除评论后还显示提醒
        [self loadData:LCUIPullLoaderDiretionTop];
    }
    
    return self;
}


-(void) buildUI
{
    self.blur = UIView.view;
    self.blur.viewFrameY = 0;
    self.blur.viewFrameWidth = self.viewFrameWidth;
    self.blur.viewFrameHeight = self.viewFrameHeight;
    self.blur.backgroundColor = LKColor.backgroundColor;
    //self.blur.tintColor = [UIColor whiteColor];
    self.ADD(self.blur);
    
    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = self.blur.bounds;
    self.tableView.backgroundView = nil;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.blur.ADD(self.tableView);
    
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

#pragma mark - 

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal)
{
    //LKPost * post = signal.object;
}

-(void) showInViewController:(UIViewController *)viewController
{
    self.userInteractionEnabled = NO;

    UIView * view = self.FIND(1002);
    view.alpha = 0;
    
    self.blur.viewFrameY = self.viewFrameHeight;
    
    [viewController.view addSubview:self];
    
    self.blur.pop_springBounciness = 2;
    self.blur.pop_springSpeed = 5;
    self.blur.pop_spring.frame = CGRectMake(0, 64, self.blur.viewFrameWidth, self.blur.viewFrameHeight);
    
    [UIView animateWithDuration:0.5 animations:^{
        
        view.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        self.userInteractionEnabled = YES;
    }];
    
}

-(void) hide
{
    if (self.willHide) {
        self.willHide();
    }
    
    UIView * view = self.FIND(1002);
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.4 animations:^{
        
        view.viewFrameY = -view.viewFrameHeight * 2;
        
        
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.blur.viewFrameY = self.viewFrameHeight;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
    
    
}

#pragma mark - 

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
        
//        return [LKNotificationCell height:notification];
        return 100;
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
