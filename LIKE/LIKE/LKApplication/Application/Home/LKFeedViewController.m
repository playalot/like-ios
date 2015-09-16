//
//  LKFeedViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKFeedViewController.h"
#import "LKHomeViewController.h"
#import "LKPost.h"
#import "LKNewPostUploadCenter.h"
#import "LKUploadingCell.h"
#import "LKHomeTableViewCell.h"
#import "LKLoginViewController.h"
#import "LKInputView.h"

@interface LKFeedViewController () <UITableViewDataSource, UITableViewDelegate, LKHomeTableViewCellDelegate>

LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(copy) NSNumber * next;
LC_PROPERTY(assign) NSTimeInterval lastFocusLoadTime;
LC_PROPERTY(assign) BOOL needRefresh;

LC_PROPERTY(weak) id delegate;

@end

@implementation LKFeedViewController

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
-(void) loadData:(LCUIPullLoaderDiretion)diretion {
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"homeFeeds"].AUTO_SESSION();
    
    if (self.next && diretion == LCUIPullLoaderDiretionBottom) {
        [interface addParameter:self.next key:@"ts"];
    }
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSNumber *resultNext = result.json[@"data"][@"next"];
            if (resultNext) {
                self.next = resultNext;
            }
            
            NSArray * resultData = result.json[@"data"][@"posts"];
            NSMutableArray * datasource = [NSMutableArray array];
            
            for (NSDictionary * tmp in resultData) {
                [datasource addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (diretion == LCUIPullLoaderDiretionTop) {
                // Change datasource and save cache...
                self.datasource = datasource;
                LKUserDefaults.singleton[self.class.description] = resultData;
            } else {
                [self.datasource addObjectsFromArray:datasource];
            }
            
            if (diretion == LCUIPullLoaderDiretionBottom) {
                [self.pullLoader endRefresh];
            }
            
            LC_FAST_ANIMATIONS(0.25, ^{
                [self.tableView reloadData];
            });
            
//            LC_APPDELEGATE.tabBarController.loading = NO;
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self.pullLoader endRefresh];
            [self showTopMessageErrorHud:result.error];
            
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

#pragma mark - ***** LKHomeTableViewCellDelegate *****
- (void)homeTableViewCell:(LKHomeTableViewCell *)cell didClickReasonBtn:(LCUIButton *)reasonBtn {
}


-(void) setDelegate:(id)delegate
{
    _delegate = delegate;
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}

@end
