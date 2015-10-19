//
//  LKRankViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/19.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRankViewController.h"
#import "LKRankInterface.h"

@interface LKRankViewController ()

LC_PROPERTY(strong) NSArray *dataSource;

@end

@implementation LKRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    self.initTableViewStyle = UITableViewStyleGrouped;
}

- (void)buildUI {

    [self buildNavigationBar];
}

- (void)buildNavigationBar {
    
    self.title = LC_LO(@"like全球排行榜");
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionHeader = UIView.view;
    sectionHeader.backgroundColor = LKColor.backgroundColor;
    sectionHeader.viewFrameWidth = LC_DEVICE_WIDTH;
    sectionHeader.viewFrameHeight = 40;
    
    LCUILabel *infoLabel = LCUILabel.view;
    infoLabel.font = LK_FONT(13);
    infoLabel.text = LC_LO(@"今日最没事干的liker");
    infoLabel.textColor = LC_RGB(153, 153, 153);
    infoLabel.viewFrameHeight = infoLabel.font.lineHeight;
    infoLabel.viewFrameWidth = [infoLabel.text sizeWithFont:LK_FONT(13) byHeight:infoLabel.viewFrameHeight].width;
    infoLabel.viewFrameX = 20;
    infoLabel.viewFrameY = (sectionHeader.viewFrameHeight - infoLabel.viewFrameHeight) * 0.5;
    sectionHeader.ADD(infoLabel);
    
    LCUILabel *increaseLabel = LCUILabel.view;
    increaseLabel.font = LK_FONT(13);
    increaseLabel.text = LC_LO(@"今日新增like");
    increaseLabel.textColor = LC_RGB(153, 153, 153);
    increaseLabel.viewFrameHeight = increaseLabel.font.lineHeight;
    increaseLabel.viewFrameWidth = [increaseLabel.text sizeWithFont:LK_FONT(13) byHeight:increaseLabel.viewFrameHeight].width;
    increaseLabel.viewFrameX = LC_DEVICE_WIDTH - increaseLabel.viewFrameWidth - 50;
    increaseLabel.viewFrameY = (sectionHeader.viewFrameHeight - increaseLabel.viewFrameHeight) * 0.5;
    sectionHeader.ADD(increaseLabel);
    
    return sectionHeader;
}

- (NSInteger)numberOfSectionsInTableView:(LCUITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 50;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LCUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Rank"];
    if (!cell) {
        
        cell = [[LCUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Rank"];
    }
    cell.textLabel.text = @"123";
    return cell;
}

- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}

- (CGFloat)tableView:(LCUITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
}

- (void)loadData {
    
    LKRankInterface *rankInterface = [[LKRankInterface alloc] init];
    
    @weakly(self);
    @weakly(rankInterface);
    
    [rankInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
       
        @normally(self);
        @normally(rankInterface);
        
        if (rankInterface.ranks) {
            self.dataSource = rankInterface.ranks;
        }
        
    } failure:^(LCBaseRequest *request) {
        
    }];
}

@end
