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
    
    self.title = LC_LO(@"群组");
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeRight image:[UIImage imageNamed:@"NavigationBarMore.png" useCache:YES] selectImage:nil];
    
//    LCUIButton *left = (LCUIButton *)self.navigationItem.leftBarButtonItem.customView;
//    left.alpha = 0;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:LC_SIZE(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    self.tableView.sectionIndexColor = LKColor.color;
    
    
    // 输入框
    self.inputView = LKGroupInputView.view;
    self.inputView.viewFrameY = LC_DEVICE_HEIGHT + 20 - self.inputView.viewFrameHeight - 49;
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
    
    return 180;

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
