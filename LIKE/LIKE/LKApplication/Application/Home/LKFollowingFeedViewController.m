//
//  LKFollowingFeedViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFollowingFeedViewController.h"
#import "LKHomeViewController.h"
#import "LKPost.h"
#import "LKNewPostUploadCenter.h"
#import "LKUploadingCell.h"
#import "LKHomeTableViewCell.h"
#import "LKLoginViewController.h"
#import "LKInputView.h"
#import "LKPostDetailViewController.h"
#import "LKFollowingFeedInterface.h"
#import "LKSearchResultsViewController.h"

#define FOCUS_FEED_CACHE_KEY [NSString stringWithFormat:@"LKFocusFeedKey-%@", LKLocalUser.singleton.user.id]

@interface LKFollowingFeedViewController () <UITableViewDataSource, UITableViewDelegate, LKPostDetailViewControllerDelegate, LKHomeTableViewCellDelegate>

LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(copy) NSNumber * next;
LC_PROPERTY(assign) NSTimeInterval lastFocusLoadTime;
LC_PROPERTY(assign) BOOL needRefresh;

LC_PROPERTY(weak) id delegate;

@end

@implementation LKFollowingFeedViewController

- (void)buildUI {
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.tableView = [[LCUITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.ADD(self.tableView);
    
    self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeaderAndFooter];
    self.pullLoader.indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    @weakly(self);
    
    self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion){
        @normally(self);
        [self loadData:diretion];
    };
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

// 这个方法同时负责主页和关注的人列表的请求
- (void)loadData:(LCUIPullLoaderDiretion)diretion {
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    LKFollowingFeedInterface *followingInterface = [[LKFollowingFeedInterface alloc] init];
    if (self.next && diretion == LCUIPullLoaderDiretionBottom) {
        followingInterface.timestamp = self.next;
    }
    
    @weakly(self);
    @weakly(followingInterface);
    
    [followingInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        
        @normally(self);
        @normally(followingInterface);
        
        NSNumber *resultNext = followingInterface.next;
        
        if (resultNext)
            self.next = resultNext;
        
        NSArray * resultData = followingInterface.posts;
        NSMutableArray * datasource = [NSMutableArray array];
        
        for (NSDictionary * tmp in resultData) {
            [datasource addObject:[LKPost objectFromDictionary:tmp]];
        }
        
        if (diretion == LCUIPullLoaderDiretionTop) {
            self.datasource = datasource;
            LKUserDefaults.singleton[FOCUS_FEED_CACHE_KEY] = resultData;
            self.lastFocusLoadTime = time;
        } else {
            [self.datasource addObjectsFromArray:datasource];
        }
        
        [self.pullLoader endRefresh];
        LC_FAST_ANIMATIONS(0.25, ^{
            [self.tableView reloadData];
        });
        
    } failure:^(LCBaseRequest *request) {
        
    }];
}

-(void) reloadData {
    [self.tableView reloadData];
}

#pragma mark - ***** 数据源方法 *****

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LKHomeTableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Content" andClass:[LKHomeTableViewCell class]];
    // 设置cell的代理
    cell.delegate = self;
    
    LKPost * post = self.datasource[indexPath.row];
    cell.post = post;
    
    @weakly(self);
    
    cell.addTag = ^(LKPost * value){
        @normally(self);
        
        if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
            self.inputView.userInfo = value;
            self.inputView.tag = indexPath.row;
            [self.inputView becomeFirstResponder];
        }
    };
    
    cell.removedTag = ^(LKPost * value){
        @normally(self);
        [self.tableView beginUpdates];
        [self reloadData];
        [self.tableView endUpdates];
    };
    
    return cell;
}

/**
 *  根据cell计算行高
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LKHomeTableViewCell height:self.datasource[indexPath.row]];
}


#pragma mark Handle Signal

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal) {
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal) {
    
    LKPostDetailViewController * detail = [[LKPostDetailViewController alloc] initWithPost:signal.object];
    // 设置代理
    detail.delegate = self;

    LCUINavigationController * nav = LC_UINAVIGATION(detail);
    
    [detail setPresendModelAnimationOpen];
    [self.navigationController presentViewController:nav animated:YES completion:nil];

    LKPost * post = signal.object;
    if ([post.tagString rangeOfString:@"Comment-"].length) {
        LKTag * tag = [[LKTag alloc] init];
        tag.id = @([post.tagString stringByReplacingOccurrencesOfString:@"Comment-" withString:@""].integerValue);
        [detail performSelector:@selector(openCommentsView:) withObject:tag afterDelay:0.35];
    }
}

#pragma mark - ***** LKPostDetailViewControllerDelegate *****
- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didDeletedTag:(LKTag *)deleteTag {
    
    for (LKPost *post in self.datasource) {
        for (LKTag *tag in post.tags) {
            
            if ([tag.tag isEqualToString:deleteTag.tag]) {
                
                // 删除标签
                [post.tags removeObject:tag];
                
                [self.tableView beginUpdates];
                [self.tableView reloadData];
                [self.tableView endUpdates];
                
                break;
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - ***** LKHomeTableViewCellDelegate *****
- (void)homeTableViewCell:(LKHomeTableViewCell *)cell didClickReasonBtn:(LCUIButton *)reasonBtn {
    if (reasonBtn.title != nil) {
        LKSearchResultsViewController *searchResultCtrl = [[LKSearchResultsViewController alloc] initWithSearchString:reasonBtn.title];
        [self.navigationController pushViewController:searchResultCtrl animated:YES];
    }
}

@end
