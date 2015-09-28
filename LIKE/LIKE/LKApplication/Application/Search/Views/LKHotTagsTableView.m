//
//  LKHotTagsTableView.m
//  LIKE
//
//  Created by huangweifeng on 9/21/15.
//  Copyright © 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHotTagsTableView.h"
#import "LKHotTagsUsersView.h"
#import "LKPostThumbnailTableViewCell.h"
#import "LKTagExploreInterface.h"
#import "LKPostTableViewController.h"

@interface LKHotTagsTableView () <UITableViewDataSource, UITableViewDelegate, LKPostTableViewControllerDelegate>

LC_PROPERTY(strong) LKTag *tagValue;
LC_PROPERTY(strong) LKHotTagsUsersView *hotUsersView;
LC_PROPERTY(strong) LCUIImageView *recommendImageView;
LC_PROPERTY(strong) LCUIImageView *lineView;
LC_PROPERTY(strong) LCUIView *headerView;

LC_PROPERTY(assign) BOOL loadFinished;
LC_PROPERTY(assign) BOOL loading;
LC_PROPERTY(assign) NSNumber *next;

LC_PROPERTY(strong) LCUIPullLoader *pullLoader;
LC_PROPERTY(strong) LKPostTableViewController *browsingViewController;

@end

@implementation LKHotTagsTableView

- (void)show {
    if (self.loading || self.loadFinished) {
        return;
    }
    [self loadData:LCUIPullLoaderDiretionTop];
}

- (void)loadData:(LCUIPullLoaderDiretion)direction {
    LKTagExploreInterface *tagExploreInterface = [[LKTagExploreInterface alloc] init];
    tagExploreInterface.tagValue = [NSString stringWithFormat:@"%@", [self.tagValue.tag URLEncoding]];
    
    if (direction == LCUIPullLoaderDiretionTop) {
        self.next = nil;
    }
    
    tagExploreInterface.timestamp = self.next;
    
    @weakly(self);
    @weakly(tagExploreInterface);
    
    [tagExploreInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        
        @normally(self);
        @normally(tagExploreInterface);
        
        NSArray *interfaceTagUsers = [tagExploreInterface users];
        if (interfaceTagUsers && interfaceTagUsers.count) {
            self.hotUsersView.hotUsers = [NSMutableArray arrayWithArray:interfaceTagUsers];
        }
        
        if (tagExploreInterface.next) {
            self.next = tagExploreInterface.next;
        }
        
        NSArray *posts = [tagExploreInterface posts];
        if (direction == LCUIPullLoaderDiretionTop) {
            if (!posts)
                posts = [NSArray array];
            self.posts = [NSMutableArray arrayWithArray:posts];
        } else {
            if (posts && posts > 0) {
                NSMutableArray *newPosts = [NSMutableArray arrayWithArray:self.posts];
                [newPosts addObjectsFromArray:posts];
                self.posts = newPosts;
            }
        }
        
        [self reloadData];
        LC_FAST_ANIMATIONS(0.25, ^{
            self.alpha = 1;
        });
        
        self.loading = NO;
        self.loadFinished = YES;
        [self.pullLoader endRefresh];
        
    } failure:^(LCBaseRequest *request) {
        
        [self.pullLoader endRefresh];
        
    }];
}

- (instancetype)initWithFrame:(CGRect)frame tag:(LKTag *)tag {
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.tagValue = tag;
        self.viewFrameY = 30;
        self.delegate = self;
        self.dataSource = self;
        self.backgroundViewColor = [UIColor whiteColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.alpha = 0;
        
        self.posts = [NSMutableArray array];
        self.headerView = [[LCUIView alloc] initWithFrame:CGRectMake(5, 5, LC_DEVICE_WIDTH - 10, 67)];
        
        self.recommendImageView = [[LCUIImageView alloc] initWithFrame:CGRectMake(20, 12, 32, 43)];
        self.recommendImageView.image = [UIImage imageNamed:@"RecommendUser.png" useCache:YES];
        self.headerView.ADD(self.recommendImageView);
        
        self.lineView = LCUIImageView.view;
        self.lineView.viewFrameX = self.recommendImageView.viewRightX + 20;
        self.lineView.viewFrameY = 13;
        self.lineView.viewFrameWidth = 1;
        self.lineView.viewFrameHeight = 40;
        self.lineView.image = [UIImage imageNamed:@"SeparateLine.png" useCache:YES];
        self.headerView.ADD(self.lineView);
        
        self.hotUsersView = [[LKHotTagsUsersView alloc] initWithFrame:CGRectMake(72, 0, LC_DEVICE_WIDTH - 10, 67)];
        self.headerView.ADD (self.hotUsersView);
        self.tableHeaderView = self.headerView;
        
        self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self pullStyle:LCUIPullLoaderStyleHeaderAndFooter];
        self.pullLoader.indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        @weakly(self);
        self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion) {
            @normally(self);
            [self loadData:diretion];
        };
    }
    return self;
}

- (instancetype)initWithTag:(LKTag *)tag {
    self = [self initWithFrame:CGRectZero tag:tag];
    if (self) {
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LKPostThumbnailTableViewCell height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger remainder = self.posts.count % 3;
    return remainder ? self.posts.count / 3 + 1 : self.posts.count / 3;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LKPostThumbnailTableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Photos" andClass:[LKPostThumbnailTableViewCell class]];
    NSInteger index = indexPath.row * 3;
    
    LKPost *post = self.posts[index];
    LKPost *post1 = index + 1 < self.posts.count ? self.posts[index + 1] : nil;
    LKPost *post2 = index + 2 < self.posts.count ? self.posts[index + 2] : nil;
    
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

#pragma mark - LKPostTableViewControllerDelegate
- (void)willLoadData:(LCUIPullLoaderDiretion)direction {
    [self loadData:direction];
}

- (void)willNavigationBack:(NSInteger)index {
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:(index / 3) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal) {
    UIResponder *currentResponder = self;
    while (![currentResponder isKindOfClass:[LKSearchViewController class]]) {
        currentResponder = currentResponder.nextResponder;
    }
    LKSearchViewController *searchViewController = (LKSearchViewController *)currentResponder;
    self.browsingViewController = [[LKPostTableViewController alloc] init];
    self.browsingViewController.delegate = self;
    self.browsingViewController.datasource = self.posts;
    self.browsingViewController.currentIndex = [self.posts indexOfObject:signal.object];
    self.browsingViewController.title = self.tagValue.tag;
    [self.browsingViewController watchForChangeOfDatasource:self dataSourceKey:@"posts"];
    [searchViewController.navigationController pushViewController:self.browsingViewController animated:YES];
}

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal) {
    UIResponder *currentResponder = self;
    while (![currentResponder isKindOfClass:[LKSearchViewController class]]) {
        currentResponder = currentResponder.nextResponder;
    }
    LKSearchViewController *searchViewController = (LKSearchViewController *)currentResponder;
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:searchViewController.navigationController];
}

@end
