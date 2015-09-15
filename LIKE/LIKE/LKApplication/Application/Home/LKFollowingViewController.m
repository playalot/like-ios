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

#define FOCUS_FEED_CACHE_KEY [NSString stringWithFormat:@"LKFocusFeedKey-%@", LKLocalUser.singleton.user.id]

@interface LKFollowingViewController ()

LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LCUITableView * tableView;

LC_PROPERTY(weak) id delegate;

LC_PROPERTY(copy) NSNumber * next;
LC_PROPERTY(copy) NSNumber * focusNext;
LC_PROPERTY(assign) NSTimeInterval lastFocusLoadTime;

@end

@implementation LKFollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundView = nil;
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
        [interface addParameter:self.focusNext key:@"ts"];
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
 
-(void) setDelegate:(id)delegate
{
    _delegate = delegate;
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}

@end
