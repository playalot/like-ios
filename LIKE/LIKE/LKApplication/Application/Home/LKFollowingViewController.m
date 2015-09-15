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

@interface LKFollowingViewController ()

LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LCUITableView * tableView;

LC_PROPERTY(weak) id delegate;

@end

@implementation LKFollowingViewController

- (void)viewDidLoad {
    [self viewDidLoad];
    
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
        [self.pullLoader endRefresh];
//        [self loadData:diretion];
    };

}

/*
-(void)loadData:(LCUIPullLoaderDiretion)diretion {
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    LC_APPDELEGATE.tabBarController.loading = YES;
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"followingFeeds"].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            self.focusNext = result.json[@"data"][@"next"] ? result.json[@"data"][@"next"] : nil;

            
            NSArray * resultData = result.json[@"data"][@"posts"];
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
            
            if (diretion == LCUIPullLoaderDiretionBottom) {
                [self.pullLoader endRefresh];
            }
            
            LC_FAST_ANIMATIONS(0.25, ^{
                
                [self.tableView reloadData];
                
            });
            
            LC_APPDELEGATE.tabBarController.loading = NO;

        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self.pullLoader endRefresh];
            
            [self showTopMessageErrorHud:result.error];
            
            LC_APPDELEGATE.tabBarController.loading = NO;
        }
        else if (result.state == LKHttpRequestStateCanceled){
            
            if (self.feedType == LKHomepageFeedTypeFocus) {
                
                [self.attentionViewController.pullLoader endRefresh];
            }
            else{
                
                [self.pullLoader endRefresh];
            }
            
            LC_APPDELEGATE.tabBarController.loading = NO;
        }
    }];
    
}
*/
 
-(void) setDelegate:(id)delegate
{
    _delegate = delegate;
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}

@end
