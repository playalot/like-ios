//
//  LKHomeFeedViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/15/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHomeFeedViewController.h"
#import "LKHomeViewController.h"
#import "LKPost.h"
#import "LKNewPostUploadCenter.h"
#import "LKUploadingCell.h"
#import "LKHomeTableViewCell.h"
#import "LKLoginViewController.h"
#import "LKInputView.h"
#import "LKPostDetailViewController.h"
#import "LKHomeFeedInterface.h"
#import "LCUIKeyBoard.h"
#import "LKTagAddModel.h"
#import "UIImageView+WebCache.h"
#import "LKSearchResultsViewController.h"
#import "SDWebImagePrefetcher.h"

#import "LKLRUCache.h"
#import "LKEditorPickInterface.h"
#import "RMPZoomTransitionAnimator.h"

#define NORMAL_CELL_IDENTIFIER @"Content"
#define PRECOMPUTED_CELL_IDENTIFIER @"Content2"

@interface LKHomeFeedCellNode : NSObject

LC_PROPERTY(strong) LKHomeTableViewCell *cell;
LC_PROPERTY(assign) CGFloat cellHeight;

@end

@implementation LKHomeFeedCellNode

@end

// Cache代码段逻辑规则

@interface LKHomeFeedViewController () <UITableViewDataSource, UITableViewDelegate, LKHomeTableViewCellDelegate, LKPostDetailViewControllerDelegate>

LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUIPullLoader *pullLoader;
LC_PROPERTY(strong) LCUITableView *tableView;
LC_PROPERTY(strong) LKInputView *inputView;

LC_PROPERTY(copy) NSNumber *next;
LC_PROPERTY(copy) NSNumber *editorPickNext;
LC_PROPERTY(assign) NSTimeInterval lastFocusLoadTime;
LC_PROPERTY(assign) BOOL needRefresh;

LC_PROPERTY(assign) BOOL isCellCached;
LC_PROPERTY(strong) LKLRUCache *cellCache;
LC_PROPERTY(strong) LKLRUCache *cellHeightCache;

LC_PROPERTY(strong) dispatch_queue_t dataQueue;

LC_PROPERTY(weak) id delegate;

@end

@implementation LKHomeFeedViewController

- (void)notificationAction {
    
}

- (void)handleNotification:(NSNotification *)notification {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = LKColor.backgroundColor;
    
    [self observeNotification:LKPostUploadSuccess];
    
    @weakly(self);
    
    LKNewPostUploadCenter.singleton.addedNewValue = ^(LKPosting * posting, NSNumber * index){
        
        @normally(self);
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index.integerValue inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        [self performSelector:@selector(scrollViewScrollToTop) withObject:nil afterDelay:0.5];
    };
    
    LKNewPostUploadCenter.singleton.uploadFinished = ^(LKPost * value, NSNumber * index){
        
        @normally(self);
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index.integerValue inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        
        if (value) {
            
            [self.datasource insertObject:value atIndex:0];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        }
    };
    
    LKNewPostUploadCenter.singleton.uploadFailed = ^(id value){
        
        @normally(self);
        
        [self reloadData];
        
        [self showTopMessageErrorHud:LC_LO(@"上传失败啦！请检查您的网络稍后再试Orz～")];
    };
    
    LKNewPostUploadCenter.singleton.stateChanged = ^(id value){
        
        @normally(self);
        
        [self reloadData];
    };
}

- (void)buildUI {
    self.dataQueue = dispatch_queue_create("HomeFeedDataHandlingQueue", NULL);
    
    [self buildCellCache];
    [self buildTableView];
    [self buildInputView];
//    [self buildBottomBar];
    [self buildPullLoader];
    [self loadData:LCUIPullLoaderDiretionTop];
}

- (void)buildBottomBar {
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, LC_DEVICE_HEIGHT + 20 - 49 - 64, LC_DEVICE_WIDTH, 49)];
    containerView.backgroundColor = [UIColor whiteColor];
    
    LCUIButton *loginButton = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, containerView.viewMidWidth, 49)];
    loginButton.title = LC_LO(@"登录");
    loginButton.titleFont = LK_FONT(14);
    loginButton.titleColor = [UIColor blackColor];
    
    LCUIButton *registButton = [[LCUIButton alloc] initWithFrame:CGRectMake(loginButton.viewRightX + 1, 0, containerView.viewMidWidth - 1, 49)];
    registButton.title = LC_LO(@"注册");
    registButton.titleFont = LK_FONT(14);
    registButton.titleColor = [UIColor blackColor];
    
    LCUIImageView *lineView = [[LCUIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparateLine.png" useCache:YES]];
    lineView.viewFrameX = loginButton.viewRightX;
    lineView.viewFrameY = 13;
    lineView.viewFrameWidth = 1;
    lineView.viewFrameHeight = 23;
    
    self.view.ADD(containerView);
    containerView.ADD(loginButton);
    containerView.ADD(lineView);
    containerView.ADD(registButton);
    
    if (![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]) {
        self.tabBarController.tabBar.hidden = NO;
        containerView.hidden = YES;
    } else {
        
        self.tabBarController.tabBar.hidden = YES;
        containerView.hidden = NO;
    }
}

- (void)buildCellCache {
    NSInteger cacheCapacity = 10;
    self.isCellCached = NO;
    self.cellCache = [[LKLRUCache alloc] initWithCapacity:cacheCapacity];
    self.cellHeightCache = [[LKLRUCache alloc] initWithCapacity:cacheCapacity];
}

- (void)buildTableView {
    CGRect viewRect;
    if (LKLocalUser.singleton.isLogin) {
        viewRect = CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 64 - 49);
    } else {
        viewRect = CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 64);
    }
    self.tableView = [[LCUITableView alloc] initWithFrame:viewRect];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.ADD(self.tableView);
}

- (void)buildPullLoader {
    self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeaderAndFooter];
    self.pullLoader.indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    @weakly(self);
    self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion){
        @normally(self);
        [self loadData:diretion];
    };
}

- (void)buildInputView {
    
    @weakly(self);
    
    self.inputView = LKInputView.view;
    self.inputView.viewFrameY = self.view.viewFrameHeight;
    self.view.ADD(self.inputView);

    self.inputView.sendAction = ^(NSString * string){
        
        @normally(self);
        
        if (string.trim.length == 0) {
            [self showTopMessageErrorHud:LC_LO(@"标签不能为空")];
            return;
        }
        
        if (string.length > 12) {
            [self showTopMessageErrorHud:LC_LO(@"标签长度不能大于12位")];
            return;
        }
        
        LKHomeTableViewCell *cell = (LKHomeTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.inputView.tag inSection:1]];
        
        // 调加标签接口
        if ([self checkTag:string onTags:((LKPost *)self.inputView.userInfo).tags]) {
            [self addTag:string onPost:self.inputView.userInfo onCell:cell];
        } else {
            [self.view showTopMessageErrorHud:LC_LO(@"该标签已存在")];
            [self.inputView resignFirstResponder];
            self.inputView.textField.text = @"";
        }
    };
    
    self.inputView.didShow = ^(){
        
        @normally(self);
        LKHomeTableViewCell * cell = (LKHomeTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.inputView.tag inSection:1]];
        CGFloat height1 = LC_DEVICE_HEIGHT - cell.viewFrameHeight;
        CGFloat height2 = LCUIKeyBoard.singleton.height + self.inputView.viewFrameHeight - height1;
        [self.tableView setContentOffset:LC_POINT(0, cell.viewFrameY + height2 - 25 + 10 + 63) animated:YES];
    };
    
    self.inputView.willDismiss = ^(id value){
    };
}

- (BOOL)checkTag:(NSString *)tag onTags:(NSArray *)onTags {
    for (LKTag * oTag in onTags) {
        if ([oTag.tag isEqualToString:tag]) {
            self.inputView.textField.text = nil;
            return NO;
        }
    }
    return YES;
}

- (void)addTag:(NSString *)tag onPost:(LKPost *)post onCell:(LKHomeTableViewCell *)cell {
    @weakly(self);
    LKTag * tagValue = [[LKTag alloc] init];
    tagValue.tag = tag;
    tagValue.likes = @1;
    tagValue.createTime = @([[NSDate date] timeIntervalSince1970]);
    tagValue.isLiked = YES;
    tagValue.user = LKLocalUser.singleton.user;
    tagValue.id = @99999999;
    
    [post.tags insertObject:tagValue atIndex:0];
    [cell reloadTags];
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath) {
        post.user.likes = @(post.user.likes.integerValue + 1);
        cell.post = post;
        [cell newTagAnimation:^(BOOL finished) {}];
    }
    
    [self.inputView resignFirstResponder];
    self.inputView.textField.text = @"";
    
    [self updatePost:post];
    
    [LKTagAddModel addTagString:tag onPost:post requestFinished:^(LKHttpRequestResult *result, NSString *error) {
        @normally(self);
        if (error) {
            [self showTopMessageErrorHud:error];
        } else {
            LKTag * tag = [LKTag objectFromDictionary:result.json[@"data"]];
            if (tag) {
                tagValue.id = tag.id;
                return;
            }
        }
        
    }];
}

// 这个方法同时负责主页和关注的人列表的请求
- (void)loadData:(LCUIPullLoaderDiretion)diretion {
    
    LKHomeFeedInterface *homeFeedInterface = [[LKHomeFeedInterface alloc] init];
    if (self.next && diretion == LCUIPullLoaderDiretionBottom) {
        homeFeedInterface.timestamp = self.next;
    }
    
    @weakly(self);
    @weakly(homeFeedInterface);
    
    [homeFeedInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        
        @normally(homeFeedInterface);
        @normally(self);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            if (homeFeedInterface.next) {
                self.next = homeFeedInterface.next;
            }
            NSArray *resultData = homeFeedInterface.posts;
            NSMutableArray * datasource = [NSMutableArray array];
            for (NSDictionary * tmp in resultData) {
                [datasource addObject:[LKPost objectFromDictionary:tmp]];
            }
            if (diretion == LCUIPullLoaderDiretionTop) {
                // 必须放在 precomputeAllTableViewCellsWithDataSource 之后
                self.datasource = datasource;
                LKUserDefaults.singleton[self.class.description] = resultData;
                if (self.isCellCached) {
                    for (NSInteger i = 0; i < datasource.count; ++i) {
                        LKPost *post = (LKPost *)datasource[i];
                        NSString *key = [NSString stringWithFormat:@"%ld", (long)i];
                        UITableViewCell *precomputedCell = [self genTableViewCell:post index:i];
                        NSNumber *cellHeight = [NSNumber numberWithFloat:[LKHomeTableViewCell height:post]];
                        [self.cellCache setObject:precomputedCell forKey:key];
                        [self.cellHeightCache setObject:cellHeight forKey:key];
                    }
                }
            } else {
                if (self.isCellCached) {
                    NSInteger beg = self.datasource.count;
                    for (NSInteger i = 0; i < datasource.count; ++i) {
                        LKPost *post = (LKPost *)datasource[i];
                        NSString *key = [NSString stringWithFormat:@"%ld", (long)i + beg];
                        UITableViewCell *precomputedCell = [self genTableViewCell:post index:i + beg];
                        NSNumber *cellHeight = [NSNumber numberWithFloat:[LKHomeTableViewCell height:post]];
                        [self.cellCache setObject:precomputedCell forKey:key];
                        [self.cellHeightCache setObject:cellHeight forKey:key];
                    }
                }
                // 必须放在 precomputeAdditionalTableViewCellsWithDataSource 之后
                [self.datasource addObjectsFromArray:datasource];
            }
            NSMutableArray *prefetchs = [NSMutableArray array];
            for (LKPost *post in self.datasource) {
                if (post.content) {
                    [prefetchs addObject:post.content];
                }
            }
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchs.copy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                @normally(self);
                [self reloadData];
                
            });
            
        });
     
    } failure:^(LCBaseRequest *request) {
        
        [self.pullLoader endRefresh];
    }];
}

- (void)reloadData {
    [self.pullLoader endRefresh];
    [self.tableView reloadData];
}

#pragma mark Handle Signal

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal) {
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal) {
    // Detail
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

LC_HANDLE_UI_SIGNAL(LKUploadingCellCancel, signal)
{
    [LKNewPostUploadCenter.singleton cancelPosting:signal.object];
}

LC_HANDLE_UI_SIGNAL(LKUploadingCellReupload, signal)
{
    [LKNewPostUploadCenter.singleton reuploadPosting:signal.object];
}

#pragma mark - ***** LKPostDetailViewControllerDelegate *****
- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didUpdatedPost:(LKPost *)post {
    NSInteger updatedIndex = -1;
    for (NSInteger i = 0; i < self.datasource.count; ++i) {
        LKPost *selfPost = self.datasource[i];
        if ([selfPost.id isEqualToNumber:post.id]) {
            updatedIndex = i;
            break;
        }
    }
    
    if (updatedIndex < 0)
        return;
    
    [self.datasource removeObjectAtIndex:updatedIndex];
    [self.datasource insertObject:post atIndex:updatedIndex];
    [self updatePost:post];
}

#pragma mark - ***** 数据源方法 *****
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return LKNewPostUploadCenter.singleton.uploadingImages.count;
    }
    
    return self.datasource.count;
}

- (UITableViewCell *)genTableViewCell:(LKPost *)post index:(NSInteger)tagValue {
    LKHomeTableViewCell *cell = [[LKHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PRECOMPUTED_CELL_IDENTIFIER];
    
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
    cell.removedTag = ^(LKPost *post) {
        @normally(self);
        [self updatePost:post];
    };
    
    return cell;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        LKUploadingCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Upload" andClass:[LKUploadingCell class]];
        cell.posting = LKNewPostUploadCenter.singleton.uploadingImages[indexPath.row];
        return cell;
    }
    
    
    LKHomeTableViewCell *cell = nil;
    
    if (self.isCellCached) {
        NSString *key = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        cell = (LKHomeTableViewCell *)[self.cellCache objectForKey:key];
        if (cell) {
            return cell;
        }
    }
    
    cell = [tableView autoCreateDequeueReusableCellWithIdentifier:NORMAL_CELL_IDENTIFIER andClass:[LKHomeTableViewCell class]];
    // 设置cell的代理
    cell.delegate = self;
    
    LKPost * post = self.datasource[indexPath.row];
    
    cell.post = post;
//    [cell setPost:post cellRow:indexPath.row];
    
    @weakly(self);
    
    cell.addTag = ^(LKPost * value){
        
        @normally(self);
        if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
            self.inputView.userInfo = value;
            self.inputView.tag = indexPath.row;
            [self.inputView becomeFirstResponder];
        }
    };
    
    cell.removedTag = ^(LKPost * post){
        @normally(self);
        [self updatePost:post];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return 38;
    }
    
    
    if (self.isCellCached) {
        NSString *key = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        NSNumber *height = [self.cellHeightCache objectForKey:key];
        if (height && height.floatValue > 0) {
            return height.floatValue;
        }
    }
    return [LKHomeTableViewCell height:self.datasource[indexPath.row]];
}

// the post passed here should be the exact object in self.datasource
- (void)updatePost:(LKPost *)post {
    if (self.datasource == nil || post == nil)
        return;
    
    if (self.isCellCached) {
        NSInteger index = [self.datasource indexOfObject:post];
        NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
        UITableViewCell *precomputedCell = [self genTableViewCell:post index:index];
        NSNumber *cellHeight = [NSNumber numberWithFloat:[LKHomeTableViewCell height:post]];
        [self.cellCache setObject:precomputedCell forKey:key];
        [self.cellHeightCache setObject:cellHeight forKey:key];
    }
    
    [self reloadData];
}

#pragma mark *****数据源******
- (void)homeTableViewCell:(LKHomeTableViewCell *)cell didClickReasonBtn:(LCUIButton *)reasonBtn {
    
    if (reasonBtn.title != nil) {
        
        if ([reasonBtn.title hasSuffix:LC_LO(@"  like推荐")]) {
            [self editorPickRequest];
        } else {
            LKSearchResultsViewController *searchResultCtrl = [[LKSearchResultsViewController alloc] initWithSearchString:reasonBtn.title];
            [self.navigationController pushViewController:searchResultCtrl animated:YES];
        }
    }
}

- (void)editorPickRequest {
    
    LKEditorPickInterface *editorPickInterface = [[LKEditorPickInterface alloc] init];
    editorPickInterface.timestamp = self.editorPickNext;
    
    @weakly(self);
    @weakly(editorPickInterface);
    
    [editorPickInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        
        @normally(editorPickInterface);
        @normally(self);
        
        if (editorPickInterface.next) {
            self.editorPickNext = editorPickInterface.next;
        }
        
        NSArray *resultData = editorPickInterface.posts;
        NSMutableArray *datasource = [NSMutableArray array];
        
        for (NSDictionary *tmp in resultData) {
            [datasource addObject:[LKPost objectFromDictionary:tmp]];
        }
        
    } failure:^(LCBaseRequest *request) {
    }];
}

#pragma mark - ***** scrollView delegate *****
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputView resignFirstResponder];
}

- (void)scrollViewScrollToTop
{
    LC_FAST_ANIMATIONS(0.25, ^{
        
        [self.tableView setContentOffset:LC_POINT(0, 0) animated:YES];
    });
}

@end
