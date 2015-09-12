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

@interface LKPostTableViewController () <LKPostDetailViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

LC_PROPERTY(strong) LCUITableView *tableView;

@end

@implementation LKPostTableViewController

-(void) dealloc
{
    [self cancelAllRequests];
    [self unobserveAllNotifications];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    if (self.datasource.count == 0)
        self.datasource = [NSMutableArray array];
    
    [self reloadData];
}

-(void) buildUI
{
    self.view.backgroundColor = LKColor.backgroundColor;
    
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
    //    self.titleView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"HomeLikeIcon.png" useCache:YES]];
    self.titleView = (UIView *)titleBtn;
    [titleBtn addTarget:self action:@selector(scrollViewScrollToTop) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    // 导航栏返回上一级按钮
    LCUIButton * backButton = LCUIButton.view;
    backButton.viewFrameWidth = 80;
    backButton.viewFrameHeight = 80;
    backButton.viewFrameY = -17;
    backButton.viewFrameX = -15;
    backButton.buttonImage = [UIImage imageNamed:@"NavigationBarBack.png" useCache:YES];
    backButton.showsTouchWhenHighlighted = YES;
    [backButton addTarget:self action:@selector(_dismissAction) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 1002;
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar addSubview:backButton];

    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.viewFrameWidth, self.view.viewFrameHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.ADD(self.tableView);
}

-(void) _dismissAction {
    [self dismissOrPopViewController];
}

#pragma mark -

-(void) addTag:(NSString *)tag onPost:(LKPost *)post onCell:(LKPostTableViewCell *)cell
{
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

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LKPostTableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Content" andClass:[LKPostTableViewCell class]];
    
    LKPost *post = self.datasource[indexPath.row];
    cell.post = post;
    
    @weakly(self);
    
    cell.addTag = ^(LKPost * value){
        
    @normally(self);
        
//        if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
//            
//            self.inputView.userInfo = value;
//            self.inputView.tag = indexPath.row;
//            
//            [self.inputView becomeFirstResponder];
//        }
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
    return [LKPostTableViewCell height:self.datasource[indexPath.row]];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void) scrollViewScrollToTop {
    NSLog(@"scrollViewScrollToTop");
}

-(void) reloadData {
    [self.tableView reloadData];
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal)
{
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