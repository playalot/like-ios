//
//  LKSearchSuggestionView.m
//  LIKE
//
//  Created by huangweifeng on 9/16/15.
//  Copyright (c) 2015 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchSuggestionView.h"
#import "LKTag.h"
#import "LKSearchHistory.h"
#import "UIImageView+WebCache.h"

@interface LKSearchSuggestionView () <UITableViewDataSource, UITableViewDelegate>

LC_PROPERTY(strong) NSArray * history;

@end

@implementation LKSearchSuggestionView

- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
    [self cancelAllRequests];
}

- (instancetype)init {
    if (self = [super init]) {
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = LCUIBlurView.view;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    [self reloadData];
}

- (void)setTags:(NSArray *)tags {
    _tags = tags;
    if (tags == nil) {
        self.users = nil;
        NSArray * history = [LKSearchHistory history];
        NSMutableArray * result = [NSMutableArray array];
        for (NSString * tagString in history) {
            LKTag * tag = [[LKTag alloc] init];
            tag.tag = tagString;
            [result addObject:tag];
        }
        self.history = result;
    }
    [self reloadData];
}

- (void)setSearchString:(NSString *)searchString tags:(NSArray *)tags {
    self.searchString = searchString;
    self.tags = tags;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.users.count) {
        return 4;
    }
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        if (!self.tags) {
            return self.history.count;
        }
        return self.tags.count;
    }
    if (section == 2) {
        return 1;
    }
    if (section == 3) {
        return self.users.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        LCUITableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Content" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            LCUILabel * label = LCUILabel.view;
            label.viewFrameX = 20;
            label.viewFrameWidth = self.viewFrameWidth;
            label.viewFrameHeight = 117. / 3.;
            label.font = LK_FONT(13);
            label.textColor = LC_RGB(79, 62, 56);
            label.tag = 1000;
            configurationCell.ADD(label);
            
            UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH;
            line.viewFrameY = 117. / 3. - line.viewFrameHeight - 0.5;
            configurationCell.ADD(line);
            
        }];
        
        LCUILabel * label = cell.FIND(1000);
        if (indexPath.section == 0) {
            if (self.tags == nil) {
                label.text = LC_LO(@"最近搜索过的标签");
            } else {
                label.text = [NSString stringWithFormat:LC_LO(@"搜索相关内容"), self.searchString];
            }
        } else {
            LKTag * tag = nil ;
            if (self.tags == nil) {
                tag = self.history[indexPath.row];
            } else {
                tag = self.tags[indexPath.row];
            }
            label.text = tag.tag;
        }
        
        return cell;
    }
    
    LCUITableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"User" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
        
        LCUIImageView * head = LCUIImageView.view;
        head.viewFrameWidth = 25;
        head.viewFrameHeight = 25;
        head.cornerRadius = 25 / 2;
        head.viewFrameX = 20;
        head.viewFrameY = 117 / 3 / 2 - 25 / 2;
        head.tag = 1001;
        configurationCell.ADD(head);
        
        LCUILabel * label = LCUILabel.view;
        label.viewFrameX = head.viewRightX + 10;
        label.viewFrameWidth = self.viewFrameWidth;
        label.viewFrameHeight = 117. / 3.;
        label.font = LK_FONT(13);
        label.textColor = LC_RGB(79, 62, 56);
        label.tag = 1000;
        configurationCell.ADD(label);
        
        UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
        line.viewFrameWidth = LC_DEVICE_WIDTH;
        line.viewFrameY = 117. / 3. - line.viewFrameHeight - 0.5;
        configurationCell.ADD(line);
        
    }];
    
    LCUIImageView * head = cell.FIND(1001);
    LCUILabel * label = cell.FIND(1000);
    
    if (indexPath.section == 2) {
        head.alpha = 0;
        label.viewFrameX = 20;
        label.text = [NSString stringWithFormat:LC_LO(@"搜索相关用户"), self.searchString];
    } else {
        LKUser * user = self.users[indexPath.row];
        [head sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil];
        label.text = user.name;
        head.alpha = 1;
        label.viewFrameX = head.viewRightX + 10;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 117 / 3;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        LKTag * tag = nil ;
        if (self.tags == nil) {
            tag = self.history[indexPath.row];
        } else {
            tag = self.tags[indexPath.row];
        }
        if (self.didSelectRow) {
            self.didSelectRow(tag.tag);
        }
    } else if (indexPath.section == 3) {
        LKUser * user = self.users[indexPath.row];
        self.SEND(@"PushUserCenter").object = user;
    }
}

@end
