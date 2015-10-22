//
//  LKRankViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/19.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKRankViewController.h"
#import "LKRankInterface.h"
#import "LKRankCell.h"
#import "LKRankMiniCell.h"

@interface LKRankViewController ()

LC_PROPERTY(strong) NSArray *dataSource;

@end

@implementation LKRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initTableViewStyle = UITableViewStyleGrouped;
}

- (void)buildUI {

    [self buildNavigationBar];
    [self buildPullLoader];
    [self loadData:LCUIPullLoaderDiretionTop];
}

- (void)buildNavigationBar {
    
    self.title = LC_LO(@"like全球排行榜");
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
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

#pragma mark Handle Signal
LC_HANDLE_UI_SIGNAL(PushUserCenter, signal) {
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ***** tableView delegate & dataSource *****
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionHeader = UIView.view;
    sectionHeader.backgroundColor = LC_RGB(248, 248, 248);
    sectionHeader.viewFrameWidth = LC_DEVICE_WIDTH;
    sectionHeader.viewFrameHeight = 38;
    
    LCUILabel *infoLabel = LCUILabel.view;
    infoLabel.font = LK_FONT(12);
    infoLabel.text = LC_LO(@"今日最没事干的liker");
    infoLabel.textColor = LC_RGB(127, 127, 127);
    infoLabel.viewFrameHeight = infoLabel.font.lineHeight;
    infoLabel.viewFrameWidth = [infoLabel.text sizeWithFont:LK_FONT(12) byHeight:infoLabel.viewFrameHeight].width;
    infoLabel.viewFrameX = 10;
    infoLabel.viewFrameY = (sectionHeader.viewFrameHeight - infoLabel.viewFrameHeight) * 0.5;
    sectionHeader.ADD(infoLabel);
    
    LCUIImageView *lineView = [[LCUIImageView alloc] initWithImage:[UIImage imageNamed:@"SeparateLine.png"]];
    lineView.viewFrameX = LC_DEVICE_WIDTH * 0.5 + 1;
    lineView.viewFrameY = 8;
    lineView.viewFrameWidth = 1;
    lineView.viewFrameHeight = 22;
    sectionHeader.ADD(lineView);
    
    LCUILabel *increaseLabel = LCUILabel.view;
    increaseLabel.font = LK_FONT(12);
    increaseLabel.text = LC_LO(@"今日新增like");
    increaseLabel.textColor = LC_RGB(127, 127, 127);
    increaseLabel.viewFrameHeight = increaseLabel.font.lineHeight;
    increaseLabel.viewFrameWidth = [increaseLabel.text sizeWithFont:LK_FONT(12) byHeight:increaseLabel.viewFrameHeight].width;
    increaseLabel.viewFrameX = LC_DEVICE_WIDTH - increaseLabel.viewFrameWidth - 15;
    increaseLabel.viewFrameY = (sectionHeader.viewFrameHeight - increaseLabel.viewFrameHeight) * 0.5;
    sectionHeader.ADD(increaseLabel);
    
    return sectionHeader;
}

- (NSInteger)numberOfSectionsInTableView:(LCUITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (UI_IS_IPHONE6PLUS) {
        LKRankCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Rank" andClass:[LKRankCell class]];
        cell.rank = self.dataSource[indexPath.row];
        return cell;
    } else {
        LKRankMiniCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"RankMini" andClass:[LKRankMiniCell class]];
        cell.rank = self.dataSource[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 51;
}

- (CGFloat)tableView:(LCUITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 38;
}

- (void)tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LKRank *rank = self.dataSource[indexPath.row];
    [LKUserCenterViewController pushUserCenterWithUser:rank.user navigationController:self.navigationController];
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    CATransform3D rotation;
//    rotation = CATransform3DMakeRotation((90.0*M_PI)/180, 0.0, 0.7, 0.4);
//    rotation.m34 = 1.0/ -600;
//    
//    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
//    cell.layer.shadowOffset = CGSizeMake(10, 10);
//    cell.alpha = 0;
//    cell.layer.transform = rotation;
//    cell.layer.anchorPoint = CGPointMake(0.5, 0.5);
//    
//    [UIView beginAnimations:@"rotation" context:NULL];
//    [UIView setAnimationDuration:0.8];
//    cell.layer.transform = CATransform3DIdentity;
//    cell.alpha = 1;
//    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    [UIView commitAnimations];
//}

- (void)loadData:(LCUIPullLoaderDiretion)diretion {
    
    LKRankInterface *rankInterface = [[LKRankInterface alloc] init];
    
    @weakly(self);
    @weakly(rankInterface);
    
    [rankInterface startWithCompletionBlockWithSuccess:^(LCBaseRequest *request) {
       
        @normally(self);
        @normally(rankInterface);
        
        if (rankInterface.ranks) {
            self.dataSource = rankInterface.ranks;
        }
        
        [self reloadData];
    } failure:^(LCBaseRequest *request) {
        [self.pullLoader endRefresh];
    }];
}

- (void)reloadData {
    [self.pullLoader endRefresh];
    [self.tableView reloadData];
}

@end
