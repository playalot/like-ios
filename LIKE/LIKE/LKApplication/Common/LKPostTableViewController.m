//
//  LKPostTableViewController.m
//  LIKE
//
//  Created by huangweifeng on 9/9/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostTableViewController.h"
#import "LKPostTableViewCell.h"
#import "LKTagAddModel.h"
#import "LKPostDetailViewController.h"
#import "LKLoginViewController.h"
#import "LKInputView.h"
#import "LCUIKeyBoard.h"

static NSString* const KVO_CONTEXT_DATASOURCE_CHANGED = @"KVO_CONTEXT_DATASOURCE_CHANGED";

@interface LKPostTableViewController () <LKPostDetailViewControllerDelegate>

LC_PROPERTY(strong) LKInputView *inputView;
LC_PROPERTY(strong) LCUIPullLoader *pullLoader;

LC_PROPERTY(assign) id observedDataSourceObject;
LC_PROPERTY(copy) NSString *observedDataSourceKeyPath;

@end

@implementation LKPostTableViewController

- (void)dealloc {
    [self cancelAllRequests];
    [self unobserveAllNotifications];
    [self.observedDataSourceObject removeObserver:self forKeyPath:self.observedDataSourceKeyPath];
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
        
        LKPostTableViewCell *cell = (LKPostTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.inputView.tag inSection:0]];
        
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
        LKPostTableViewCell * cell = (LKPostTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.inputView.tag inSection:0]];
        CGFloat height1 = LC_DEVICE_HEIGHT - cell.viewFrameHeight;
        CGFloat height2 = LCUIKeyBoard.singleton.height + self.inputView.viewFrameHeight - height1;
        [self.tableView setContentOffset:LC_POINT(0, cell.viewFrameY + height2 - 25 + 10 + 63) animated:YES];
    };
    
    self.inputView.willDismiss = ^(id value){
    };
}

- (void)buildUI {
    self.view.backgroundColor = LKColor.backgroundColor;
    
    if (self.datasource == nil)
        self.datasource = [NSMutableArray array];
    [self reloadData];
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];

    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.viewFrameWidth, self.view.viewFrameHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.ADD(self.tableView);
    
    [self setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeaderAndFooter];
    @weakly(self);
    self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion) {
        @normally(self);
        [self loadData:diretion];
    };
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self buildInputView];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)loadData:(LCUIPullLoaderDiretion)diretion {
    if (self.delegate) {
        [self.delegate willLoadData:diretion];
    }
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
        
        NSIndexPath *visibleIndexPath = [[self.tableView indexPathsForVisibleRows] objectAtIndex:0];
        if (self.delegate) {
            [self.delegate willNavigationBack:visibleIndexPath.row];
        }
        
    }
}

- (void)watchForChangeOfDatasource:(id)observedDataSourceObject
                     dataSourceKey:(NSString *)observedDataSourceKeyPath {
    
    self.observedDataSourceObject = observedDataSourceObject;
    self.observedDataSourceKeyPath = observedDataSourceKeyPath;
    
    [observedDataSourceObject addObserver:self
                               forKeyPath:observedDataSourceKeyPath
                                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                  context:(__bridge_retained void *)KVO_CONTEXT_DATASOURCE_CHANGED];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == (__bridge_retained void *)KVO_CONTEXT_DATASOURCE_CHANGED){
        NSArray *datasource = [object valueForKey:self.observedDataSourceKeyPath];
        self.datasource = [NSMutableArray arrayWithArray:datasource];
        [self.pullLoader endRefresh];
        [self reloadData];
    }
}

- (void)refresh {
    if (self.tableView) {
        [self.tableView reloadData];
    }
}

#pragma mark -

- (BOOL)checkTag:(NSString *)tag onTags:(NSArray *)onTags {
    for (LKTag * oTag in onTags) {
        if ([oTag.tag isEqualToString:tag]) {
            return NO;
        }
    }
    return YES;
}

- (void)addTag:(NSString *)tag onPost:(LKPost *)post onCell:(LKPostTableViewCell *)cell {
    @weakly(self);
    LKTag * tagValue = [[LKTag alloc] init];
    tagValue.tag = tag;
    tagValue.likes = @1;
    tagValue.createTime = @([[NSDate date] timeIntervalSince1970]);
    tagValue.isLiked = YES;
    tagValue.user = LKLocalUser.singleton.user;
    tagValue.id = @99999999;
    
    [post.tags insertObject:tagValue atIndex:0];
    
    // reload tags...
    [cell reloadTags];
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    // reload row...
    if (indexPath) {
        post.user.likes = @(post.user.likes.integerValue + 1);
        [self.tableView beginUpdates];
        cell.post = post;
        [self.tableView endUpdates];
        [cell newTagAnimation:^(BOOL finished) {}];
    }
    
    // input view...
    [self.inputView resignFirstResponder];
    
    [LKTagAddModel addTagString:tag onPost:post requestFinished:^(LKHttpRequestResult *result, NSString *error) {
        @normally(self);
        
        if (error) {
            [self showTopMessageErrorHud:error];
        } else {
            // insert...
            LKTag * tag = [LKTag objectFromDictionary:result.json[@"data"]];
            if (tag) {
                tagValue.id = tag.id;
                return;
            }
        }
        
    }];
}

#pragma mark - ***** 数据源方法 *****

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LKPostTableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Content" andClass:[LKPostTableViewCell class]];
    
    cell.headLineHidden = self.cellHeadLineHidden;
    
    LKPost *post = self.datasource[indexPath.row];
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
    
    [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    
    return cell;
}

/**
 *  根据cell计算行高
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LKPostTableViewCell height:self.datasource[indexPath.row] headLineHidden:self.cellHeadLineHidden];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void) scrollViewScrollToTop {
}

-(void) reloadData {
    [self.tableView reloadData];
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal) {
    
    if (self.inputView.isFirstResponder) {
        [self.inputView resignFirstResponder];
        return;
    }
    
    if ([LKLoginViewController needLoginOnViewController:self.navigationController]) {
        return;
    }
    
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

@end
