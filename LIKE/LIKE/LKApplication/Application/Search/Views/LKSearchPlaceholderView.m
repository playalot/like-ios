//
//  LKSearchPlaceholderView.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/26.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSearchPlaceholderView.h"
#import "LKTag.h"
#import "LKSearchHistory.h"

@interface LKSearchPlaceholderView () <UITableViewDataSource,UITableViewDelegate>

LC_PROPERTY(strong) NSArray * history;

@end

@implementation LKSearchPlaceholderView

-(void) dealloc
{
    self.delegate = nil;
    self.dataSource = nil;
    
    [self cancelAllRequests];
}

-(instancetype) init
{
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

-(void) setSearchString:(NSString *)searchString
{
    _searchString = searchString;
        
    [self reloadData];
}

-(void) setTags:(NSArray *)tags
{
    _tags = tags;
    
    if (tags == nil) {
        
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

-(void) setSearchString:(NSString *)searchString tags:(NSArray *)tags
{
    self.searchString = searchString;
    self.tags = tags;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    if (!self.tags) {
        
        return self.history.count;
    }
    
    return self.tags.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        line.viewFrameY = 117. / 3. - line.viewFrameHeight;
        configurationCell.ADD(line);
        
    }];
    
    LCUILabel * label = cell.FIND(1000);
    
    if (indexPath.section == 0) {
        
        if (self.tags == nil) {
            
            label.text = LC_LO(@"最近搜索过的标签");
        }
        else{
        
            label.text = [NSString stringWithFormat:@"%@\"%@\"%@", LC_LO(@"搜索"), self.searchString, LC_LO(@"相关内容")];
        }
    }
    else{
  
        LKTag * tag = nil ;
        
        if (self.tags == nil) {
            
            tag = self.history[indexPath.row];
        }
        else{
        
            tag = self.tags[indexPath.row];
        }
        
        label.text = tag.tag;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 117 / 3;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        
        LKTag * tag = nil ;
        
        if (self.tags == nil) {
            
            tag = self.history[indexPath.row];
        }
        else{
            
            tag = self.tags[indexPath.row];
        }
        
        if (self.didSelectRow) {
            self.didSelectRow(tag.tag);
        }
    }
    
}

@end
