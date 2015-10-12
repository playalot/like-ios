//
//  LKProfileDetailViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/10/12.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKProfileDetailViewController.h"

@interface LKProfileDetailViewController ()

@end

@implementation LKProfileDetailViewController

- (void)buildUI {
    
    [self.navigationController setNavigationBarHidden:NO];
    [self buildNavigationBar];
}

- (void)buildNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
    self.titleView = (UIView *)titleBtn;
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ***** TableView DataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LCUITableViewCell *cell = nil;
    
    cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Action" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
        
        configurationCell.backgroundColor = [UIColor clearColor];
        configurationCell.contentView.backgroundColor = [UIColor clearColor];
        configurationCell.selectedViewColor = LKColor.backgroundColor;
        
        
        LCUIButton *icon = LCUIButton.view;
        icon.viewFrameX = 18;
        icon.viewFrameY = 13;
        icon.viewFrameWidth = 29;
        icon.viewFrameHeight = 29;
        icon.tag = 1001;
        configurationCell.ADD(icon);
        
        
        LCUILabel *label = LCUILabel.view;
        label.viewFrameX = icon.viewRightX + 18;
        label.viewFrameWidth = 150;
        label.viewFrameHeight = 55;
        label.font = LK_FONT(13);
        label.textColor = LC_RGB(51, 51, 51);
        label.tag = 1002;
        configurationCell.ADD(label);
        
        
        LCUIButton *linkButton = LCUIButton.view;
        linkButton.title = LC_LO(@"绑定");
        linkButton.titleFont = LK_FONT(13);
        linkButton.titleColor = LC_RGB(153, 153, 153);
        linkButton.viewFrameHeight = linkButton.titleFont.lineHeight;
        linkButton.viewFrameWidth = [linkButton.title sizeWithFont:LK_FONT(13) byHeight:linkButton.viewFrameHeight].width;
        linkButton.viewFrameX = LC_DEVICE_WIDTH - linkButton.viewFrameWidth - 16;
        linkButton.viewFrameY = (55 - linkButton.viewFrameHeight) * 0.5;
        configurationCell.ADD(linkButton);
        
        
        UIView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
        line.viewFrameWidth = LC_DEVICE_WIDTH;
        line.viewFrameY = 55 - line.viewFrameHeight;
        configurationCell.ADD(line);
    }];
    
    
    LCUIButton *icon = cell.FIND(1001);
    LCUILabel *label = cell.FIND(1002);
    
    NSArray *icons = @[@"FacebookLogin.png", @"WeChatLogin.png", @"WeiboLogin.png", @"PhoneIcon.png"];
    NSArray *titles = @[LC_LO(@"facebook"), LC_LO(@"微信"), LC_LO(@"微博"), LC_LO(@"手机号")];
    icon.buttonImage = [UIImage imageNamed:icons[indexPath.row] useCache:YES];
    label.text = titles[indexPath.row];
    
    return cell;
}

#pragma mark - ***** TableView Delegate *****
- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 55;
}

- (void)tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
