//
//  LKFollowingViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFollowingViewController.h"
#import "LKHomeViewController.h"
#import "LKPost.h"
#import "LKNewPostUploadCenter.h"
#import "LKUploadingCell.h"
#import "LKHomeTableViewCell.h"
#import "LKLoginViewController.h"
#import "LKInputView.h"
#import "LKPostDetailViewController.h"

#define FOCUS_FEED_CACHE_KEY [NSString stringWithFormat:@"LKFocusFeedKey-%@", LKLocalUser.singleton.user.id]

@interface LKFollowingViewController () <UITableViewDataSource, UITableViewDelegate, LKHomeTableViewCellDelegate, LKPostDetailViewControllerDelegate>

LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(copy) NSNumber * next;
LC_PROPERTY(assign) NSTimeInterval lastFocusLoadTime;
LC_PROPERTY(assign) BOOL needRefresh;

LC_PROPERTY(weak) id delegate;

@end

@implementation LKFollowingViewController

- (void)buildUI {
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.tableView = [[LCUITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.ADD(self.tableView);
    
    self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleFooter];
    self.pullLoader.indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    @weakly(self);
    
    self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion){
        @normally(self);
        [self loadData:diretion];
    };
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

// 这个方法同时负责主页和关注的人列表的请求
-(void) loadData:(LCUIPullLoaderDiretion)diretion
{
    //    if (LC_APPDELEGATE.tabBarController.loading) {
    //        [self.pullLoader endRefresh];
    //        return;
    //    }
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    //    if (self.feedType == LKHomepageFeedTypeFocus && diretion == LCUIPullLoaderDiretionTop) {
    //        if (time - self.lastFocusLoadTime < 30) {
    //            return;
    //        }
    //    }
    
    //    LC_APPDELEGATE.tabBarController.loading = YES;
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"followingFeeds"].AUTO_SESSION();
    
    if (self.next && diretion == LCUIPullLoaderDiretionBottom) {
        [interface addParameter:self.next key:@"ts"];
    }
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSNumber *resultNext = result.json[@"data"][@"next"];
            if (resultNext)
                self.next = resultNext;
            
            NSArray * resultData = result.json[@"data"][@"posts"];
            NSMutableArray * datasource = [NSMutableArray array];
            
            for (NSDictionary * tmp in resultData) {
                [datasource addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (diretion == LCUIPullLoaderDiretionTop) {
                
                self.datasource = datasource;
                LKUserDefaults.singleton[FOCUS_FEED_CACHE_KEY] = resultData;
                
                self.lastFocusLoadTime = time;
            }
            else{
                
                [self.datasource addObjectsFromArray:datasource];
            }
            
            if (diretion == LCUIPullLoaderDiretionBottom) {
                
                [self.pullLoader endRefresh];
                
            }
            
            LC_FAST_ANIMATIONS(0.25, ^{
                [self.tableView reloadData];
            });
            
            //            [LC_APPDELEGATE.tabBarController.loading = NO;
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self.pullLoader endRefresh];
            
            //            LC_APPDELEGATE.tabBarController.loading = NO;
        }
        else if (result.state == LKHttpRequestStateCanceled){
            
            [self.pullLoader endRefresh];
            
            //            LC_APPDELEGATE.tabBarController.loading = NO;
        }
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
    
//    [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    
    return cell;
}

/**
 *  根据cell计算行高
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LKHomeTableViewCell height:self.datasource[indexPath.row]];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        // 减速的时候调用
        if (scrollView.contentOffset.y < -80) {
            self.needRefresh = YES;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.needRefresh) {
        [self loadData:LCUIPullLoaderDiretionTop];
        self.needRefresh = NO;
    }
}

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal) {
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
    [LC_APPDELEGATE.tabBarController hideBar];
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
    
//    if (reasonBtn.title != nil) {
//        
//        LKSearchResultsViewController *searchResultCtrl = [[LKSearchResultsViewController alloc] initWithSearchString:reasonBtn.title];
//        [self.navigationController pushViewController:searchResultCtrl animated:YES];
//    }
}


-(void) setDelegate:(id)delegate
{
    _delegate = delegate;
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}

@end
