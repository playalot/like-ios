//
//  LKGroupViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/9/16.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKGroupViewController.h"
#import "LKGroupTableViewCell.h"
#import "LKPostTagsDetailModel.h"
#import "LKGroupInputView.h"
#import "LKPost.h"

@interface LKGroupViewController ()

LC_PROPERTY(strong) NSMutableArray *dataSource;
LC_PROPERTY(strong) LKGroupInputView *inputView;
LC_PROPERTY_MODEL(LKPostTagsDetailModel, tagsListModel);

@end

@implementation LKGroupViewController

- (instancetype)init {
    
    if (self = [super init]) {
        
        [self sendNetworkRequest];
    }
    
    return self;
}

- (void)sendNetworkRequest {
    
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:@"homeFeeds"].GET_METHOD();
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * resultData = result.json[@"data"][@"posts"];
            NSMutableArray * datasource = [NSMutableArray array];
            
            for (NSDictionary * tmp in resultData) {
                
                [datasource addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            self.dataSource = datasource;
            
            [self reloadData];
            
        } else if (result.state == LKHttpRequestStateFailed) {
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)buildUI {
    
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.title = LC_LO(@"群组");
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeRight image:[UIImage imageNamed:@"NavigationBarMore.png" useCache:YES] selectImage:nil];
        
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:LC_SIZE(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    self.tableView.sectionIndexColor = LKColor.color;
    
    
    // 输入框
    self.inputView = LKGroupInputView.view;
    self.inputView.viewFrameY = LC_DEVICE_HEIGHT + 20 - self.inputView.viewFrameHeight;
    [UIApplication sharedApplication].keyWindow.ADD(self.inputView);
    
    @weakly(self);
    
    self.inputView.sendAction = ^(NSString * text){
        
        @normally(self);
        
        if (text.trim.length == 0) {
            
            [self showTopMessageErrorHud:LC_LO(@"评论不能为空")];
            return;
        }
    };
}

/**
 *  根据导航栏按钮类型处理相关操作
 */
- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        [self.inputView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        [self moreAction];
    }
}

- (void)moreAction {
    
    [self.inputView resignFirstResponder];
    
    @weakly(self);
    
    [LKActionSheet showWithTitle:nil buttonTitles:@[LC_LO(@"查看群组成员"), LC_LO(@"申请管理员"), LC_LO(@"屏蔽该群组")] didSelected:^(NSInteger index) {
        
        @normally(self);
        
        if (index == 0){
            
            NSLog(@"查看群组成员  %s", __FUNCTION__);
            
        } else if (index == 1) {
            
            NSLog(@"申请管理员   %s", __FUNCTION__);
            
        } else if (index == 2){
            
            NSLog(@"屏蔽该群组   %s", __FUNCTION__);

        }
    }];
}

#pragma mark - ***** tableView dataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseID = @"Group";
    
    LKGroupTableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:reuseID andClass:[LKGroupTableViewCell class]];
    
    cell.cellIndexPath = indexPath;
    cell.post = self.dataSource[indexPath.row];
    
//    cell.textLabel.textColor = [UIColor redColor];
//    cell.textLabel.text = [NSString stringWithFormat:@"随机数:%@", self.dataSource[indexPath.row]];
    
    return cell;
}

#pragma mark - ***** tableView Delegate *****
- (void)tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LKPost *post = self.dataSource[indexPath.row];
    
    CGFloat height = [LKGroupTableViewCell height:post];
    
    if (indexPath.row == self.dataSource.count - 1) {
        
        height += 5;
    }
    
    return 370;
}

#pragma mark - ***** scrollView Delegate *****-
-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.inputView resignFirstResponder];
}

#pragma mark - ***** 懒加载 *****
- (NSMutableArray *)dataSource {
    
    if (_dataSource == nil) {
        
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
