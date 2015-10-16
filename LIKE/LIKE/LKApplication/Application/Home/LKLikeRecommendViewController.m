//
//  LKLikeRecommendViewController.m
//  LIKE
//
//  Created by huangweifeng on 10/16/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLikeRecommendViewController.h"
#import "LKPostThumbnailTableViewCell.h"
#import "LKPostDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "LKPostTableViewController.h"
#import "LKLikeRecommendInterface.h"

@interface LKLikeRecommendViewController () <LKPostTableViewControllerDelegate>

LC_PROPERTY(copy) NSString * searchString;
LC_PROPERTY(assign) NSInteger page;
LC_PROPERTY(strong) NSDictionary * info;
LC_PROPERTY(strong) NSDictionary *tagInfo;
LC_PROPERTY(strong) LCUIButton *subscribeBtn;
LC_PROPERTY(getter=isSubscribed) BOOL subscribed;

LC_PROPERTY(strong) NSNumber *timestamp;

@end

@implementation LKLikeRecommendViewController

- (void)dealloc {
    [self cancelAllRequests];
}

- (instancetype)init {
    if (self = [super init]) {
        self.initTableViewStyle = UITableViewStyleGrouped;
    }
    return self;
}

-(void) buildUI {
    self.title = LC_LO(@"Like推荐");
    self.view.backgroundColor = LKColor.backgroundColor;
    
    [self buildNavigationBar];
    
    // 订阅标签按钮
    LCUIButton *subscribeBtn = LCUIButton.view;
    self.subscribeBtn = subscribeBtn;
    subscribeBtn.hidden = YES;
    subscribeBtn.viewFrameWidth = 66;
    subscribeBtn.viewFrameHeight = 22;
    [subscribeBtn setImage:[UIImage imageNamed:@"Subscribe.png" useCache:YES] forState:UIControlStateNormal];
    [subscribeBtn setImage:[UIImage imageNamed:@"CancelSubscribe.png" useCache:YES] forState:UIControlStateSelected];
    // 添加弹簧
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = -8;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)subscribeBtn];
    self.navigationItem.rightBarButtonItems = @[fixedSpace, rightItem];
    [subscribeBtn addTarget:self action:@selector(subscribeTag:) forControlEvents:UIControlEventTouchUpInside];
    // 判别是否显示订阅标签
//    [self judgeSubscribeTag];
    
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
    
    LKLikeRecommendInterface *interface = [[LKLikeRecommendInterface alloc] init];
    if (self.timestamp && diretion == LCUIPullLoaderDiretionBottom) {
        interface.timestamp = self.timestamp;
    }
    
    @weakly(self);
    @weakly(interface);
    
    [interface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        
        @normally(self);
        @normally(interface);
        
        if (interface.next) {
            self.timestamp = interface.next;
        }
        
        if (interface.info) {
            self.info = interface.info;
        }
        
        NSArray *resultData = interface.posts;
        
        if (diretion == LCUIPullLoaderDiretionTop) {
            self.datasource = [NSMutableArray arrayWithArray:resultData];
        } else {
            NSMutableArray *newDataSource = [NSMutableArray arrayWithArray:self.datasource];
            [newDataSource addObjectsFromArray:resultData];
            self.datasource = newDataSource;
        }
        
        [self.pullLoader endRefresh];
        [self reloadData];
        
    } failure:^(LCBaseRequest *request) {
        [self.pullLoader endRefresh];
        
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
    LKPostTableViewController *browsingViewController = [[LKPostTableViewController alloc] init];
    browsingViewController.delegate = self;
    browsingViewController.datasource = self.datasource;
    browsingViewController.currentIndex = [self.datasource indexOfObject:signal.object];
    browsingViewController.title = self.title;
    [browsingViewController watchForChangeOfDatasource:self dataSourceKey:@"datasource"];
    [self.navigationController pushViewController:browsingViewController animated:YES];
}

@end
