//
//  LKProfileSettingViewController.m
//  LIKE
//
//  Created by Elkins.Zhao on 15/9/28.
//  Copyright © 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKProfileSettingViewController.h"
#import "LKLinkAccountsViewController.h"
#import "LCUIImageCache.h"
#import "SDImageCache.h"
#import "LKInputTextViewController.h"
#import "LKProfileInfoModifyViewController.h"

@interface LKProfileSettingViewController ()

LC_PROPERTY(assign) CGFloat cacheSize;

@end

@implementation LKProfileSettingViewController

- (void)buildUI {
    
    [self.navigationController setNavigationBarHidden:NO];
    [self buildNavigationBar];
    [self buildCacheSize];
    [self buildTip];
}

- (void)buildNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    self.title = LC_LO(@"设置");
}

- (void)buildCacheSize {
    
    self.cacheSize = 0;
    [LCGCD dispatchAsync:LCGCDPriorityDefault block:^{
        
        self.cacheSize = [self getCacheSize];
        
        [LCGCD dispatchAsyncInMainQueue:^{
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }];
    }];
}

- (void)buildTip {
    
    LCUILabel *version = LCUILabel.view;
    version.viewFrameHeight = 28;
    version.viewFrameWidth = LC_DEVICE_WIDTH;
    version.viewFrameY = 55 * 5 + 100 + 20;
    version.numberOfLines = 0;
    version.textColor = LC_RGB(51, 51, 51);
    version.font = LK_FONT(10);
    version.textAlignment = UITextAlignmentCenter;
    version.text = [NSString stringWithFormat:@"Version %@ Build %@\n© 2015 Like Co. Ltd", [LCSystemInfo appVersion], [LCSystemInfo appBuildVersion]];
    self.tableView.ADD(version);
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ***** TableView DataSource *****
- (NSInteger)tableView:(LCUITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 6;
}

- (LCUITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LCUITableViewCell *cell = nil;
    
    if (indexPath.row < 5) {
        
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
            
            
            LCUIImageView *indicatorView = LCUIImageView.view;
            indicatorView.viewFrameWidth = 11;
            indicatorView.viewFrameHeight = 20;
            indicatorView.viewFrameX = LC_DEVICE_WIDTH - 16 - 11;
            indicatorView.viewFrameY = 17.5;
            indicatorView.image = [UIImage imageNamed:@"RightArrow.png" useCache:YES];
            configurationCell.ADD(indicatorView);
            
            
            UIView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH;
            line.viewFrameY = 55 - line.viewFrameHeight;
            configurationCell.ADD(line);
        }];
        
        
        LCUIButton *icon = cell.FIND(1001);
        LCUILabel *label = cell.FIND(1002);
        
        NSArray *icons = @[@"SettingHead.png", @"SettingBinding.png", @"DeleteCache.png", @"Appstore.png", @"Feedback.png"];
        NSArray *titles = @[LC_LO(@"个人设置"), LC_LO(@"绑定账号"), LC_LO(@"清除缓存"), LC_LO(@"求鼓励"), @"@CEO"];
        icon.buttonImage = [UIImage imageNamed:icons[indexPath.row] useCache:YES];
        label.text = titles[indexPath.row];
        
    } else {
        
        cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Exit" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            LCUIButton *logoutButton = LCUIButton.view;
            logoutButton.viewFrameX = 50;
            logoutButton.viewFrameY = 30;
            logoutButton.viewFrameWidth = LC_DEVICE_WIDTH - 100;
            logoutButton.viewFrameHeight = 40;
            logoutButton.title = LC_LO(@"退出登录");
            logoutButton.titleColor = [UIColor whiteColor];
            logoutButton.titleFont = LK_FONT(13);
            logoutButton.backgroundColor = LKColor.color;
            logoutButton.cornerRadius = 4;
            logoutButton.showsTouchWhenHighlighted = YES;
            [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
            configurationCell.ADD(logoutButton);
        }];
    }

    return cell;
}

- (void)logout {
    [self.navigationController popViewControllerAnimated:YES];
    [LKLocalUser logout];
    [[LKNavigator navigator] launchGuestMode];
}

#pragma mark - ***** TableView Delegate *****
- (CGFloat)tableView:(LCUITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 5) {
        
        return 100;
    }
    return 55;
}

- (void)tableView:(LCUITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        LKProfileInfoModifyViewController *modifyViewController = [LKProfileInfoModifyViewController viewController];
        [self.navigationController pushViewController:modifyViewController animated:YES];
        
    } else if (indexPath.row == 1) {
        
        LKLinkAccountsViewController *linkViewController = [LKLinkAccountsViewController viewController];
        [self.navigationController pushViewController:linkViewController animated:YES];
        
    } else if (indexPath.row == 2) {
        
        [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"确定要清除缓存吗？") cancelTitle:LC_LO(@"取消") otherTitle:LC_LO(@"确定") didTouchedBlock:^(NSInteger integerValue) {
            
            if (integerValue == 1) {
                
                [self showTopLoadingMessageHud:LC_LO(@"删除中...")];
                
                [LCGCD dispatchAsync:LCGCDPriorityHigh block:^{
                    
                    [LCUIImageCache.singleton deleteAllImages];
                    self.cacheSize = 0;
                    
                    [[SDImageCache sharedImageCache] clearDisk];
                    
                    [LCGCD dispatchAsyncInMainQueue:^{
                        
                        [RKDropdownAlert dismissAllAlert];
                        
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    }];
                }];
            }
        }];
    } else if (indexPath.row == 3) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=975648403&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        
    } else if (indexPath.row == 4) {
        
        LKInputTextViewController *input = [LKInputTextViewController viewController];
        @weakly(self);
        input.inputFinished = ^(NSString * string){
            @normally(self);
            [self uploadFeedback:string];
        };
        input.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController pushViewController:input animated:YES];
    }
}

-(void) uploadFeedback:(NSString *)feedback {
    [self showTopLoadingMessageHud:LC_LO(@"提交中...")];
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"feedback"].AUTO_SESSION().POST_METHOD();
    [interface addParameter:feedback key:@"feedback"];
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        if (result.state == LKHttpRequestStateFinished) {
            
            [RKDropdownAlert dismissAllAlert];
            
            [LCUIAlertView showWithTitle:nil message:LC_LO(@"感谢您的反馈！") cancelTitle:LC_LO(@"好的") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
                
            }];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [RKDropdownAlert dismissAllAlert];
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

// MB
-(CGFloat) getCacheSize
{
    NSString *cachePath = LCUIImageCache.singleton.fileCache.cachePath;
    NSString *sdCachePath = [NSString stringWithFormat:@"%@/Library/Caches/default/com.hackemist.SDWebImageCache.default", NSHomeDirectory()];
    CGFloat LCImageCacheSize = [self folderSizeAtPath:cachePath];
    CGFloat sdCacheSize = [self folderSizeAtPath:sdCachePath];
    return  LCImageCacheSize + sdCacheSize;
}

- (long long) fileSizeAtPath:(NSString *) filePath
{
    NSFileManager * manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//遍历文件夹获得文件夹大小，返回多少M
- (CGFloat) folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager * manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:folderPath]) return 0;
    
    NSEnumerator * childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString * fileName;
    
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    
    return folderSize / (1024.0 * 1024.0);
}

@end
