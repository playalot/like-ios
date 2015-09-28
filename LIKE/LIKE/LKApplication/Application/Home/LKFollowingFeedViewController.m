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
#import "LRUCache.h"

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

LC_PROPERTY(assign) BOOL isCellPrecomuted;
LC_PROPERTY(strong) NSMutableArray *precomputedCells;
LC_PROPERTY(strong) LRUCache *precomputedCellCache;

LC_PROPERTY(weak) id delegate;

@end

@implementation LKFollowingFeedViewController

- (void)refresh {
    [self.tableView reloadData];
}

- (void)calculateHeightList {
    self.heightList = [NSMutableArray array];
    for (LKPost *post in self.datasource) {
        [self.heightList addObject:[NSNumber numberWithFloat:[LKHomeTableViewCell height:post]]];
    }
}

- (void)buildUI {
    
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
    
    
    [self buildCellCache];
    [self loadData:LCUIPullLoaderDiretionTop];
}

- (void)buildCellCache {
    self.isCellPrecomuted = YES;
    self.precomputedCells = [NSMutableArray array];
    self.precomputedCellCache = [[LRUCache alloc] initWithCapacity:10];
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
            
            if (self.isCellPrecomuted) {
                [self precomputeAllTableViewCellsWithDataSource:datasource];
            }
            
            self.datasource = datasource;
            LKUserDefaults.singleton[FOCUS_FEED_CACHE_KEY] = resultData;
            self.lastFocusLoadTime = time;
            
            self.heightList = [NSMutableArray array];
            for (LKPost *post in self.datasource) {
                [self.heightList addObject:[NSNumber numberWithFloat:[LKHomeTableViewCell height:post]]];
            }
            
        } else {
            
            if (self.isCellPrecomuted) {
                [self precomputeAdditionalTableViewCellsWithDataSource:datasource];
            }
            
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
        
        [self.pullLoader endRefresh];
        [self.tableView reloadData];
     
    } failure:^(LCBaseRequest *request) {
        
    }];
}

- (void)precomputeAllTableViewCellsWithDataSource:(NSArray *)datasource {
    for (NSInteger i = 0; i < datasource.count; ++i) {
        LKPost *post = (LKPost *)datasource[i];
        NSString *key = [NSString stringWithFormat:@"%ld", (long)i];
        UITableViewCell *precomputedCell = [self getTableViewCell:post inputViewTag:i];
        [self.precomputedCellCache setObject:precomputedCell forKey:key];
    }
}

- (void)precomputeAdditionalTableViewCellsWithDataSource:(NSArray *)datasource {
    NSInteger beg = self.datasource.count;
    for (NSInteger i = 0; i < datasource.count; ++i) {
        LKPost *post = (LKPost *)datasource[i];
        NSString *key = [NSString stringWithFormat:@"%ld", (long)i + beg];
        UITableViewCell *precomputedCell = [self getTableViewCell:post inputViewTag:i + beg];
        [self.precomputedCellCache setObject:precomputedCell forKey:key];
    }
}

- (UITableViewCell *)getTableViewCell:(LKPost *)post inputViewTag:(NSInteger)tagValue {
    LKHomeTableViewCell *cell = [[LKHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Content"];
    // 设置cell的代理
    cell.delegate = self;
    cell.post = post;
    @weakly(self);
    cell.addTag = ^(LKPost * value){
        @normally(self);
        if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
            self.inputView.userInfo = value;
            self.inputView.tag = tagValue;
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
    
    LKHomeTableViewCell *cell = nil;
    
    if (self.isCellPrecomuted) {
        NSString *key = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        cell = (LKHomeTableViewCell *)[self.precomputedCellCache objectForKey:key];
        if (cell) {
            return cell;
        }
    }
    
    cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Content" andClass:[LKHomeTableViewCell class]];
    
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
