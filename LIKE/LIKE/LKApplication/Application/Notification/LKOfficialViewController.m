//
//  LKOfficialViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/18.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKOfficialViewController.h"
#import "LKNormalOfficialCell.h"
#import "LKNotificationOfficialCell.h"
#import "LKOfficialDetailViewController.h"

@interface LKOfficialViewController ()

@end

@implementation LKOfficialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = LKColor.backgroundColor;
}

- (void)buildUI {
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ***** tableView dataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        LKNormalOfficialCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"NormalCell" andClass:[LKNormalOfficialCell class]];
        cell.titleLbl.text = @"iOS 9.1 出现神秘表情，猜猜代表啥功能";
        cell.subTitleLbl.text = @"号外号外，据称 iOS 9.1 和 OS X 10.11.1 将会有一个新的 emoji 表情，叫做“eye in speech bubble（对话泡泡里的眼睛）”。没有人知道它究竟代表咋个意思。\n该表情由 Emojipedia 的 Jeremy Burge 在最新的 iOS 9.1 和 OS X 10.11.1 开发者版本中发现。它并非是标准的 Unicode 标志符号，而是两个 Unicode 7 的表情组合。Burge 发现，新的“eye in speech bubble”表情并没有被 Unicode 提到或推荐过。";
        cell.cellBackgroundView.cornerRadius = 5;
        return cell;
    } else {
        
        LKNotificationOfficialCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"LargeCell" andClass:[LKNotificationOfficialCell class]];
        cell.titleLbl.text = @"苹果：iOS 9 安装普及率超50%，iPhone 6s 卖得好";
        cell.subTitleLbl.text = @"北京时间9月21日晚间消息，苹果公司(以下简称“苹果”)今日宣布，iOS 9仅用5天时间就普及到50%的iOS设备上，成为历史上普及速度最快的iOS平台。\n iOS 9上周三面向iOS用户开放下载。苹果今日宣布，50%多的iPhone、iPad和iPod touch用户已升级到iOS 9，成为苹果历史上普及速度最快的iOS系统。\n 苹果负责全球营销的高级副总裁菲利普·席勒(Phil Schiller)在一份声明中称：“iOS 9的快速普及令人吃惊，它有望成为苹果历史上下载量最高的软件。”\n 苹果公布的数据要比外界的预期更高。第三方研究机构Mixpanel之前曾表示，iOS 9当前已被安装在约30%的iPhone、iPad和iPod touch中。苹果的数据来自对iOS设备对App Store应用商店访问量的分析，而Mixpanel的数据来自对Web访问数据的分析。";
        cell.cellBackgroundView.cornerRadius = 5;
        return cell;
    }
}

#pragma mark - ***** tableView delegate *****
- (void)tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LKOfficialDetailViewController *detailCtrl = [LKOfficialDetailViewController viewController];
    [self.navigationController pushViewController:detailCtrl animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[LKNormalOfficialCell class]]) {
        
        LKNormalOfficialCell *normalCell = (LKNormalOfficialCell *)cell;
        return normalCell.cellHeight;
    } else if ([cell isKindOfClass:[LKNotificationOfficialCell class]]) {
        
        LKNotificationOfficialCell *largeCell = (LKNotificationOfficialCell *)cell;
        return largeCell.cellHeight;
    }
    
    return 100;
}

@end
