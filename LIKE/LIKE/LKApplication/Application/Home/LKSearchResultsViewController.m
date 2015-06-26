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

LC_PROPERTY(strong) NSDictionary * info;

@end

@implementation LKSearchResultsViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) initWithSearchString:(NSString *)searchString
{
    if (self = [super init]) {
        
        self.initTableViewStyle = UITableViewStyleGrouped;
        self.searchString = searchString;
    }
    
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide status bar.
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
    
    
    // hide navigation bar.
    [self setNavigationBarHidden:NO animated:animated];
    
}


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
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            id tmp = result.json[@"data"];
        
            NSArray * datasource = nil;
        
            NSMutableArray * resultData = [NSMutableArray array];
            
            if ([tmp isKindOfClass:[NSDictionary class]]) {
                
                datasource = tmp[@"posts"];
                
                self.info = tmp[@"info"];
            }
            else{
                
                datasource = tmp;
            }
            
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

-(UIView *) buildHeader
{
    if (!self.info) {
        return nil;
    }
    
    
    NSString * avatar = self.info[@"avatar"];
    NSString * description = self.info[@"description"];
    
    UIView * view = [UIView view];

    LCUIImageView * head = LCUIImageView.view;
    head.viewFrameWidth = 66;
    head.viewFrameHeight = 66;
    head.viewFrameX = 15;
    head.viewFrameY = 15;
    head.backgroundColor = [UIColor lightGrayColor];
    head.url = avatar;
    head.cornerRadius = 4;
    view.ADD(head);
    
    
    LCUILabel * label = LCUILabel.view;
    label.viewFrameX = head.viewRightX + 15;
    label.viewFrameY = 15;
    label.viewFrameWidth = LC_DEVICE_WIDTH - label.viewFrameX - 15;
    label.numberOfLines = 0;
    label.text = description;
    label.font = LK_FONT(12);
    label.textColor = LC_RGB(140, 133, 126);
    label.FIT();
    view.ADD(label);
    
    
    view.viewFrameWidth = LC_DEVICE_WIDTH;
    view.viewFrameHeight = label.viewBottomY + 15 < 96 ? 96 : label.viewBottomY + 15;
    
    
    return view;
}

-(CGFloat) headerHeight
{
    if (!self.info) {
        return 0.01;
    }
    
    return [self buildHeader].viewFrameHeight;
}

#pragma mark -

-(CGFloat) tableView:(LCUITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self headerHeight];
}

-(CGFloat) tableView:(LCUITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self buildHeader];
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

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
    //nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    //[self.navigationController pushViewController:postDetail animated:YES];
    [self.navigationController  presentViewController:nav animated:YES completion:nil];
}

@end
