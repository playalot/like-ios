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

@interface LKHotTagsTableView () <UITableViewDataSource, UITableViewDelegate>

LC_PROPERTY(strong) LKTag * tagValue;
LC_PROPERTY(strong) LKHotTagsUsersView *hotUsersView;
LC_PROPERTY(strong) NSMutableArray *posts;

LC_PROPERTY(assign) BOOL loadFinished;
LC_PROPERTY(assign) BOOL loading;

@end

@implementation LKHotTagsTableView

- (void)show {
    if (self.loading || self.loadFinished) {
        return;
    }
    [self sendNetWorkRequestWithTimestamp:nil];
}

- (void)sendNetWorkRequestWithTimestamp:(NSNumber *)timestamp {
    LKTagExploreInterface *tagExploreInterface = [[LKTagExploreInterface alloc] init];
    tagExploreInterface.tagValue = [NSString stringWithFormat:@"%@", [self.tagValue.tag URLEncoding]];
    tagExploreInterface.timestamp = timestamp;
    
    @weakly(self);
    @weakly(tagExploreInterface);
    
    [tagExploreInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
        
        @normally(self);
        @normally(tagExploreInterface);
        
        self.hotUsersView.hotUsers = [tagExploreInterface users];
        NSArray *posts = [tagExploreInterface posts];
        
        if (timestamp) {
            [self.posts addObjectsFromArray:posts];
        } else {
            if (!posts) {
                posts = [NSArray array];
            }
            self.posts = [NSMutableArray arrayWithArray:posts];
        }
        
        [self reloadData];
        LC_FAST_ANIMATIONS(0.25, ^{
            self.alpha = 1;
        });
        
        self.loading = NO;
        self.loadFinished = YES;
        
    } failure:^(LCBaseRequest *request) {
        
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
        
        self.hotUsersView = [[LKHotTagsUsersView alloc] initWithFrame:CGRectMake(5, 5, LC_DEVICE_WIDTH - 10, 82)];
        self.tableHeaderView = self.hotUsersView;
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



@end
