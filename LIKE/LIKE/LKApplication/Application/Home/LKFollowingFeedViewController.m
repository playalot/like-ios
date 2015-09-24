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
#import "SDWebImagePrefetcher.h"
#import "LKLikeTagItemView.h"
#import "LKPostTableViewCell.h"
#import "LKPostView.h"

#define FOCUS_FEED_CACHE_KEY [NSString stringWithFormat:@"LKFocusFeedKey-%@", LKLocalUser.singleton.user.id]

@interface LKFollowingFeedViewController () <UITableViewDataSource, UITableViewDelegate, LKPostDetailViewControllerDelegate, LKHomeTableViewCellDelegate>

LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(copy) NSNumber * next;
LC_PROPERTY(assign) NSTimeInterval lastFocusLoadTime;
LC_PROPERTY(assign) BOOL needRefresh;
LC_PROPERTY(strong) NSMutableArray *heightList;
LC_PROPERTY(strong) NSOperationQueue *loadDataQueue;

LC_PROPERTY(weak) id delegate;

@end

@implementation LKFollowingFeedViewController

- (void)calculateHeightList {
    self.heightList = [NSMutableArray array];
    for (LKPost *post in self.datasource) {
        [self.heightList addObject:[NSNumber numberWithFloat:[LKHomeTableViewCell height:post]]];
    }
}

- (void)buildTestTagsView {
    
    NSMutableArray *tagList = [NSMutableArray array];
    
    NSArray *tagStringList = @[@"海贼王", @"天使", @"火影忍者", @"海神", @"花千骨", @"变态", @"骨干", @"连接服务器", @"北京技术交流"];
    
    for (NSInteger i = 0; i < tagStringList.count; i++) {
        LKTag *tag = [[LKTag alloc] init];
        tag.tag = tagStringList[i];
        [tagList addObject:tag];
    }
    
    LKPostView *postView = [[LKPostView alloc] initWithFrame:self.view.bounds];
    postView.tagList = tagList;
    self.view = postView;
}

- (void)buildUI {
    
    self.loadDataQueue = [[NSOperationQueue alloc] init];
    
    CGRect viewRect = CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 64 - 49);
    self.tableView = [[LCUITableView alloc] initWithFrame:viewRect];
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
        
        NSBlockOperation *dataHandlingOperation = [NSBlockOperation blockOperationWithBlock:^{
            
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
                
                self.heightList = [NSMutableArray array];
                for (LKPost *post in self.datasource) {
                    [self.heightList addObject:[NSNumber numberWithFloat:[LKHomeTableViewCell height:post]]];
                }
                
            } else {
                [self.datasource addObjectsFromArray:datasource];
                
                // Calculate Height List
                for (LKPost *post in datasource) {
                    [self.heightList addObject:[NSNumber numberWithFloat:[LKHomeTableViewCell height:post]]];
                }
            }
            
            NSMutableArray *prefetchs = nil;
            for (LKPost *post in self.datasource) {
                if (post.content) {
                    [prefetchs addObject:post.content];
                }
            }
            
            [self calculateHeightList];
            
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchs.copy];
            
            
            NSBlockOperation *refreshOperation = [NSBlockOperation blockOperationWithBlock:^{
                [self.pullLoader endRefresh];
                [self.tableView reloadData];
            }];
            [[NSOperationQueue mainQueue] addOperation:refreshOperation];
        }];
        
        [self.loadDataQueue addOperation:dataHandlingOperation];
        
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
    
//    LKPostTableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Content" andClass:[LKPostTableViewCell class]];
    
    // 设置cell的代理
//    cell.delegate = self;
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.heightList[indexPath.row] floatValue];
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
