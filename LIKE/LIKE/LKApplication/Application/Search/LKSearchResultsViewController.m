//
//  LKSearchResultsViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchResultsViewController.h"
#import "LKPostThumbnailTableViewCell.h"
#import "LKPostDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "LKPostTableViewController.h"
#import "LKSearchTagInterface.h"

@interface LKSearchResultsViewController () <LKPostTableViewControllerDelegate>

LC_PROPERTY(copy) NSString * searchString;
LC_PROPERTY(assign) NSInteger page;
LC_PROPERTY(strong) NSDictionary * info;
LC_PROPERTY(strong) NSDictionary *tagInfo;
LC_PROPERTY(strong) LCUIButton *subscribeBtn;
LC_PROPERTY(getter=isSubscribed) BOOL subscribed;

LC_PROPERTY(strong) NSNumber *timestamp;

LC_PROPERTY(strong) LKPostTableViewController *browsingViewController;

@end

@implementation LKSearchResultsViewController

- (void)dealloc {
    [self cancelAllRequests];
}

- (instancetype)initWithSearchString:(NSString *)searchString {
    if (self = [super init]) {
        self.initTableViewStyle = UITableViewStyleGrouped;
        self.searchString = searchString;
    }
    return self;
}

-(void) buildUI {
    self.title = self.searchString;
    
    [self buildNavigationBar];
    
    // 订阅标签按钮
    LCUIButton *subscribeBtn = LCUIButton.view;
    self.subscribeBtn = subscribeBtn;
    subscribeBtn.hidden = YES;
    subscribeBtn.viewFrameWidth = 56;
    subscribeBtn.viewFrameHeight = 29;
    [subscribeBtn setImage:[UIImage imageNamed:@"Subscribe.png" useCache:YES] forState:UIControlStateNormal];
    [subscribeBtn setImage:[UIImage imageNamed:@"CancelSubscribe.png" useCache:YES] forState:UIControlStateSelected];
    // 添加弹簧
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = -8;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)subscribeBtn];
    self.navigationItem.rightBarButtonItems = @[fixedSpace, rightItem];
    [subscribeBtn addTarget:self action:@selector(subscribeTag:) forControlEvents:UIControlEventTouchUpInside];
    // 判别是否显示订阅标签
    [self judgeSubscribeTag];
    
    @weakly(self);
    
    [self setPullLoaderStyle:LCUIPullLoaderStyleHeaderAndFooter beginRefresh:^(LCUIPullLoaderDiretion diretion) {
        @normally(self);
        [self loadData:diretion];
    }];
    
    [self.pullLoader performSelector:@selector(startRefresh) withObject:nil afterDelay:0.01];
}

- (void)buildNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 判别是否显示订阅标签
- (void)judgeSubscribeTag {
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"tag/%@/subscribe", self.searchString.URLCODE()]].GET_METHOD();
    @weakly(self);
    [self request:interface complete:^(LKHttpRequestResult *result) {
        @normally(self);
        if (result.state == LKHttpRequestStateFinished) {
            NSDictionary *tmp = result.json[@"data"];
            if (tmp[@"tag"]) {
                
                // 显示订阅按钮
                NSDictionary *tagInfo = tmp[@"tag"];
                self.tagInfo = tagInfo;
                self.subscribed = [tagInfo[@"subscribed"] boolValue];
                self.subscribeBtn.hidden = NO;
                self.subscribeBtn.selected = self.isSubscribed;
                
            } else {
                
                // 隐藏订阅按钮
                self.subscribeBtn.hidden = YES;
            }
        } else if (result.state == LKHttpRequestStateFailed) {
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

// 订阅标签
- (void)subscribeTag:(LCUIButton *)subscribeBtn {
    subscribeBtn.selected = !subscribeBtn.isSelected;
    LKHttpRequestInterface *interface = nil;
    if (subscribeBtn.isSelected) {
        interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"tag/%@/subscribe", self.tagInfo[@"id"]]].POST_METHOD();
    } else {
        interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"tag/%@/subscribe", self.tagInfo[@"id"]]].DELETE_METHOD();
    }
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        if (result.state == LKHttpRequestStateFinished) {
        } else if (result.state == LKHttpRequestStateFailed) {
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

- (void)scrollToPostByIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:(index / 3) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)loadData:(LCUIPullLoaderDiretion)diretion {
    NSInteger page = 0;
    if (diretion == LCUIPullLoaderDiretionBottom) {
        page = self.page + 1;
    }
    
    if (diretion == LCUIPullLoaderDiretionTop) {
        self.timestamp = nil;
    }

    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"search/tag/%@", self.searchString.URLCODE()]].GET_METHOD();
    
    if (self.timestamp) {
        interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"search/tag/%@?ts=%@", self.searchString.URLCODE(), self.timestamp]].GET_METHOD();
    }
    
    @weakly(self);
    [self request:interface complete:^(LKHttpRequestResult * result) {
        @normally(self);
        if (result.state == LKHttpRequestStateFinished) {
            id tmp = result.json[@"data"];
            NSArray * datasource = nil;
            NSMutableArray * resultData = [NSMutableArray array];
            if ([tmp isKindOfClass:[NSDictionary class]]) {
                datasource = tmp[@"posts"];
                self.info = tmp[@"info"];
            } else {
                datasource = tmp;
            }
            
            for (NSDictionary * tmp in datasource) {
                [resultData addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (diretion == LCUIPullLoaderDiretionTop) {
                self.datasource = resultData;
            } else {
                NSMutableArray *newDataSource = [NSMutableArray arrayWithArray:self.datasource];
                [newDataSource addObjectsFromArray:resultData];
                self.datasource = newDataSource;
            }
            
            self.page = page;
            [self.pullLoader endRefresh];
            [self reloadData];
            
        } else if (result.state == LKHttpRequestStateFailed){
            [self showTopMessageErrorHud:result.error];
            [self.pullLoader endRefresh];
        }
    }];

}

#pragma mark -

- (UIView *)buildHeader {
    
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
    head.backgroundColor = LKColor.backgroundColor;
    [head sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:nil];
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

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LKPostThumbnailTableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Photos" andClass:[LKPostThumbnailTableViewCell class]];
    NSInteger index = indexPath.row * 3;
    
    NSArray * datasource = self.datasource;
    LKPost * post = datasource[index];
    LKPost * post1 = index + 1 < datasource.count ? datasource[index + 1] : nil;
    LKPost * post2 = index + 2 < datasource.count ? datasource[index + 2] : nil;
    
    NSMutableArray * array = [NSMutableArray array];
    
    if (post)
        [array addObject:post];
    
    if (post1)
        [array addObject:post1];
    
    if (post2)
        [array addObject:post2];
    
    cell.posts = array;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LKPostThumbnailTableViewCell height];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - LKPostTableViewControllerDelegate
- (void)willLoadData:(LCUIPullLoaderDiretion)direction {
    [self loadData:direction];
}

- (void)willNavigationBack:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:(index / 3) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal) {
    self.browsingViewController = [[LKPostTableViewController alloc] init];
    self.browsingViewController.delegate = self;
    self.browsingViewController.datasource = self.datasource;
    self.browsingViewController.currentIndex = [self.datasource indexOfObject:signal.object];
    self.browsingViewController.title = self.searchString;
    [self.browsingViewController watchForChangeOfDatasource:self dataSourceKey:@"datasource"];
    [self.navigationController pushViewController:self.browsingViewController animated:YES];
}

@end
