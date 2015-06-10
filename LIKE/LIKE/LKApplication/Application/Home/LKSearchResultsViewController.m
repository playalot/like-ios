//
//  LKSearchResultsViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchResultsViewController.h"
#import "LKUserCenterPhotoCell.h"
#import "LKPostDetailViewController.h"

@interface LKSearchResultsViewController ()

LC_PROPERTY(copy) NSString * searchString;
LC_PROPERTY(strong) NSMutableArray * datasource;
LC_PROPERTY(assign) NSInteger page;

@end

@implementation LKSearchResultsViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) initWithSearchString:(NSString *)searchString
{
    if (self = [super init]) {
        
        self.searchString = searchString;
    }
    
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide status bar.
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    
    // hide navigation bar.
    [self setNavigationBarHidden:NO animated:animated];
    
}

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


-(void) buildUI
{
    self.title = self.searchString;
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];

    
    @weakly(self);
    
    [self setPullLoaderStyle:LCUIPullLoaderStyleHeaderAndFooter beginRefresh:^(LCUIPullLoaderDiretion diretion) {
        
        @normally(self);
        
        [self loadData:diretion];
        
    }];
    
    [self.pullLoader performSelector:@selector(startRefresh) withObject:nil afterDelay:0.01];
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) loadData:(LCUIPullLoaderDiretion)diretion
{
    NSInteger page = 0;
    
    if (diretion == LCUIPullLoaderDiretionBottom) {
        page = self.page + 1;
    }
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"tag/search/%@/%@", self.searchString.URLCODE(), @(page)]].AUTO_SESSION();
    interface.customAPIURL = LK_API2;
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * datasource = result.json[@"data"];
            
            NSMutableArray * resultData = [NSMutableArray array];
            
            for (NSDictionary * tmp in datasource) {
                
                [resultData addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (diretion == LCUIPullLoaderDiretionTop) {
                
                self.datasource = resultData;
            }
            else{
                
                [self.datasource addObjectsFromArray:resultData];
            }
            
            self.page = page;
            
            [self.pullLoader endRefresh];
            [self reloadData];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
            
            [self.pullLoader endRefresh];
        }
    }];

}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger remainder = self.datasource.count % 3;
    
    return remainder ? self.datasource.count / 3 + 1 : self.datasource.count / 3;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LKUserCenterPhotoCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Photos" andClass:[LKUserCenterPhotoCell class]];
    
    NSInteger index = indexPath.row * 3;
    
    NSArray * datasource = self.datasource;
    
    LKPost * post = datasource[index];
    LKPost * post1 = index + 1 < datasource.count ? datasource[index + 1] : nil;
    LKPost * post2 = index + 2 < datasource.count ? datasource[index + 2] : nil;
    
    NSMutableArray * array = [NSMutableArray array];
    
    if (post) {
        [array addObject:post];
    }
    
    if (post1) {
        [array addObject:post1];
    }
    
    if (post2) {
        [array addObject:post2];
    }
    
    cell.posts = array;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [LKUserCenterPhotoCell height];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal)
{
    LKPost * post = signal.object;
    
    LKPostDetailViewController * postDetail = [[LKPostDetailViewController alloc] initWithPost:post];
    UINavigationController * nav = LC_UINAVIGATION(postDetail);
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

@end
