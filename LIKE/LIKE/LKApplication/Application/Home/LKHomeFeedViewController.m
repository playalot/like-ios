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


@interface LKHomeFeedViewController () <UITableViewDataSource, UITableViewDelegate, LKHomeTableViewCellDelegate, LKPostDetailViewControllerDelegate>

LC_PROPERTY(strong) NSMutableArray *datasource;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(copy) NSNumber * next;
LC_PROPERTY(assign) NSTimeInterval lastFocusLoadTime;
LC_PROPERTY(assign) BOOL needRefresh;

LC_PROPERTY(strong) LKHomeFeedInterface *homeFeedInterface;
LC_PROPERTY(strong) NSMutableArray *heightList;

LC_PROPERTY(assign) BOOL isCellPrecomuted;
LC_PROPERTY(strong) NSMutableArray *precomputedCells;

LC_PROPERTY(weak) id delegate;

@end

@implementation LKHomeFeedViewController

- (void)buildUI {
    [self buildTableView];
    [self buildInputView];
    [self buildPullLoader];
    
    self.isCellPrecomuted = YES;
    self.precomputedCells = [NSMutableArray array];
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

- (void)buildTableView {
    
    CGRect viewRect = CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20 - 64 - 49);
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
        
        // scroll...
        LKHomeTableViewCell * cell = (LKHomeTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.inputView.tag inSection:0]];
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
        [self.tableView beginUpdates];
        cell.post = post;
        [self.tableView endUpdates];
        [cell newTagAnimation:^(BOOL finished) {}];
    }
    
    [self.inputView resignFirstResponder];
    self.inputView.textField.text = @"";
    
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
        
        if (homeFeedInterface.next) {
            self.next = homeFeedInterface.next;
        }
        
        NSArray *resultData = homeFeedInterface.posts;
        NSMutableArray * datasource = [NSMutableArray array];
        
        for (NSDictionary * tmp in resultData) {
            [datasource addObject:[LKPost objectFromDictionary:tmp]];
        }
        
        if (diretion == LCUIPullLoaderDiretionTop) {
            self.datasource = datasource;
            LKUserDefaults.singleton[self.class.description] = resultData;
            
            // Calculate Height List
            self.heightList = [NSMutableArray array];
            for (LKPost *post in self.datasource) {
                [self.heightList addObject:[NSNumber numberWithFloat:[LKHomeTableViewCell height:post]]];
            }
            
            if (self.isCellPrecomuted) {
                [self precomputeAllTableViewCellsWithDataSource:datasource];
            }
            
        } else {
            [self.datasource addObjectsFromArray:datasource];
            
            // Calculate Height List
            for (LKPost *post in datasource) {
                [self.heightList addObject:[NSNumber numberWithFloat:[LKHomeTableViewCell height:post]]];
            }
            
            if (self.isCellPrecomuted) {
                [self precomputeAdditionalTableViewCellsWithDataSource:datasource];
            }
        }
        
        NSMutableArray *prefetchs = [NSMutableArray array];
        for (LKPost *post in self.datasource) {
            if (post.content) {
                [prefetchs addObject:post.content];
            }
        }
        
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchs.copy];

        [self.pullLoader endRefresh];
        [self.tableView reloadData];
     
    } failure:^(LCBaseRequest *request) {
        
    }];
}

- (void)reloadData {
    [self.tableView reloadData];
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

#pragma mark - ***** 数据源方法 *****
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (void)precomputeAllTableViewCellsWithDataSource:(NSArray *)datasource {
    self.precomputedCells = [NSMutableArray array];
    for (NSInteger i = 0; i < datasource.count; ++i) {
        LKPost *post = (LKPost *)datasource[i];
        [self.precomputedCells addObject:[self getTableViewCell:post inputViewTag:i]];
    }
}

- (void)precomputeAdditionalTableViewCellsWithDataSource:(NSArray *)datasource {
    NSInteger beg = self.precomputedCells.count;
    for (NSInteger i = 0; i < datasource.count; ++i) {
        LKPost *post = (LKPost *)datasource[i];
        [self.precomputedCells addObject:[self getTableViewCell:post inputViewTag:i + beg]];
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

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isCellPrecomuted) {
        return [self.precomputedCells objectAtIndex:indexPath.row];
    }
    
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.heightList[indexPath.row] floatValue];
}

#pragma mark *****数据源******
- (void)homeTableViewCell:(LKHomeTableViewCell *)cell didClickReasonBtn:(LCUIButton *)reasonBtn {
    if (reasonBtn.title != nil) {
        LKSearchResultsViewController *searchResultCtrl = [[LKSearchResultsViewController alloc] initWithSearchString:reasonBtn.title];
        [self.navigationController pushViewController:searchResultCtrl animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.inputView resignFirstResponder];
}

@end
