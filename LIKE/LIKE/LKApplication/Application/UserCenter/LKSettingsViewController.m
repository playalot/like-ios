//
//  LKSettingsViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/22.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKSettingsViewController.h"
#import "LCUIImageCache.h"
#import "LKInputTextViewController.h"
#import "LKUploadAvatarAndCoverModel.h"
#import "LKModifyUserInfoModel.h"
#import "LKUserInfoModel.h"
#import "LKLinkAccountsViewController.h"

@interface LKSettingsViewController () <UITableViewDataSource,UITableViewDelegate>

LC_PROPERTY(strong) LCUIBlurView * blur;
LC_PROPERTY(strong) LCUITableView * tableView;

LC_PROPERTY(strong) LCUIImageView * head;
LC_PROPERTY(strong) LCUITextField * nickField;

LC_PROPERTY(assign) CGFloat cacheSize;

@end

@implementation LKSettingsViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20)]) {
        
        [self buildUI];
    }
    
    return self;
}

-(void) buildUI
{
    UIView * header = UIView.view;
    header.frame = CGRectMake(0, 0, self.viewFrameWidth, 64);
    [header addTapGestureRecognizer:self selector:@selector(hide)];
    self.ADD(header);
    
    
    LCUIButton * backButton = LCUIButton.view;
    backButton.viewFrameWidth = 54;
    backButton.viewFrameHeight = 55 / 3 + 44;
    backButton.viewFrameY = 10;
    backButton.buttonImage = [UIImage imageNamed:@"NavigationBarDismiss.png" useCache:YES];
    backButton.showsTouchWhenHighlighted = YES;
    [backButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 1002;
    [self addSubview:backButton];
    
    
    self.blur = LCUIBlurView.view;
    self.blur.viewFrameY = 64;
    self.blur.viewFrameWidth = self.viewFrameWidth;
    self.blur.viewFrameHeight = self.viewFrameHeight - 64;
    self.blur.tintColor = [UIColor whiteColor];
    self.ADD(self.blur);
    
    
    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = self.blur.bounds;
    self.tableView.backgroundView = nil;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.blur.ADD(self.tableView);
    
    
    LCUILabel * version = LCUILabel.view;
    version.viewFrameHeight = 28;
    version.viewFrameWidth = LC_DEVICE_WIDTH;
    version.viewFrameY = self.tableView.viewFrameHeight + 20;
    version.numberOfLines = 0;
    version.textColor = LC_RGB(51, 51, 51);
    version.font = LK_FONT(10);
    version.textAlignment = UITextAlignmentCenter;
    version.text = [NSString stringWithFormat:@"Version %@ Build %@\n© 2015 Like Co. Ltd", [LCSystemInfo appVersion], [LCSystemInfo appBuildVersion]];
    self.tableView.ADD(version);
    
    self.cacheSize = 0;
    
    
    [LCGCD dispatchAsync:LCGCDPriorityDefault block:^{
        
        self.cacheSize = [self getCacheSize];

        [LCGCD dispatchAsyncInMainQueue:^{
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

        }];
    }];
}



#pragma mark -

-(NSInteger) numberOfSectionsInTableView:(LCUITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView * view = UIView.view;
//    view.viewFrameWidth = LC_DEVICE_WIDTH;
//    view.viewFrameHeight = 20;
//    
//    return view;
//}
//
//-(CGFloat) tableView:(LCUITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0;
//}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LCUITableViewCell * cell = nil;
    
    if (indexPath.row == 0) {
        
        cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Head" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {

            
            configurationCell.backgroundColor = [UIColor clearColor];
            configurationCell.contentView.backgroundColor = [UIColor clearColor];
            
            LCUIButton * icon = LCUIButton.view;
            icon.viewFrameX = 40;
            icon.viewFrameWidth = 20;
            icon.viewFrameHeight = 20;
            icon.viewFrameY = 200 / 3 / 2 - 20 / 2;
            icon.tag = 1001;
            icon.image = [UIImage imageNamed:@"SettingHead.png" useCache:YES];
            configurationCell.ADD(icon);
            
            
            LCUILabel * label = LCUILabel.view;
            label.viewFrameX = icon.viewRightX + 20;
            label.viewFrameWidth = LC_DEVICE_WIDTH;
            label.viewFrameHeight = 200 / 3;
            label.font = LK_FONT(13);
            label.textColor = LC_RGB(51, 51, 51);
            label.tag = 1002;
            label.text = LC_LO(@"修改头像");
            configurationCell.ADD(label);
            
            
            self.head = LCUIImageView.view;
            self.head.viewFrameWidth = 40;
            self.head.viewFrameHeight = 40;
            self.head.viewFrameX = LC_DEVICE_WIDTH - 40 - 40;
            self.head.viewFrameY = 200 / 3 / 2 - 20;
            self.head.cornerRadius = 20;
            self.head.image = nil;
            self.head.url = LKLocalUser.singleton.user.avatar;
            configurationCell.ADD(self.head);
            
            
            
            UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH - 40;
            line.viewFrameX = 20;
            line.viewFrameY = 200 / 3 - line.viewFrameHeight;
            configurationCell.ADD(line);

        }];
        

        
    }
    else if (indexPath.row == 1){
        
        cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Nick" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.backgroundColor = [UIColor clearColor];
            configurationCell.contentView.backgroundColor = [UIColor clearColor];
            
            LCUIButton * icon = LCUIButton.view;
            icon.viewFrameX = 40;
            icon.viewFrameWidth = 20;
            icon.viewFrameHeight = 20;
            icon.viewFrameY = 200 / 3 / 2 - 20 / 2;
            icon.tag = 1001;
            icon.image = [UIImage imageNamed:@"SettingNick.png" useCache:YES];
            configurationCell.ADD(icon);
            
            
            LCUILabel * label = LCUILabel.view;
            label.viewFrameX = icon.viewRightX + 20;
            label.viewFrameWidth = LC_DEVICE_WIDTH;
            label.viewFrameHeight = 200 / 3;
            label.font = LK_FONT(13);
            label.textColor = LC_RGB(51, 51, 51);
            label.tag = 1002;
            label.text = LC_LO(@"修改昵称");
            configurationCell.ADD(label);
            
            
            
            self.nickField = LCUITextField.view;
            self.nickField.viewFrameX = LC_DEVICE_WIDTH / 2;
            self.nickField.viewFrameWidth = LC_DEVICE_WIDTH / 2 - 40;
            self.nickField.viewFrameHeight = 200 / 3;
            self.nickField.font = LK_FONT(11);
            self.nickField.textColor = LC_RGB(180, 180, 180);
            self.nickField.textAlignment = UITextAlignmentRight;
            self.nickField.text = LKLocalUser.singleton.user.name;
            self.nickField.returnKeyType = UIReturnKeyDone;
            configurationCell.ADD(self.nickField);
            
            @weakly(self);
            
            self.nickField.shouldReturn = ^BOOL(id value){
              
                @normally(self);
                
                if (self.nickField.text.length <= 0) {
                    
                    return NO;
                }
                
                [self.nickField resignFirstResponder];
                
                [LKModifyUserInfoModel setNewName:self.nickField.text requestFinished:^(NSString *error) {
                    
                    if (!error) {
                        
                        [self.fromViewController.userInfoModel getUserInfo:self.fromViewController.user.id];
                    }
                }];
                
                return YES;
            };
            
            
            UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH - 40;
            line.viewFrameX = 20;
            line.viewFrameY = 200 / 3 - line.viewFrameHeight;
            configurationCell.ADD(line);
            
        }];
        
        
    }
    else if (indexPath.row < 6){
        
        cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Action" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.backgroundColor = [UIColor clearColor];
            configurationCell.contentView.backgroundColor = [UIColor clearColor];
            
            LCUIButton * icon = LCUIButton.view;
            icon.viewFrameX = 40;
            icon.viewFrameWidth = 20;
            icon.viewFrameHeight = 20;
            icon.viewFrameY = 200 / 3 / 2 - 20 / 2;
            icon.tag = 1001;
            configurationCell.ADD(icon);
            
            
            LCUILabel * label = LCUILabel.view;
            label.viewFrameX = icon.viewRightX + 20;
            label.viewFrameWidth = LC_DEVICE_WIDTH;
            label.viewFrameHeight = 200 / 3;
            label.font = LK_FONT(13);
            label.textColor = LC_RGB(51, 51, 51);
            label.tag = 1002;
            configurationCell.ADD(label);
            
            
            LCUILabel * subLabel = LCUILabel.view;
            subLabel.viewFrameX = 20;
            subLabel.viewFrameWidth = LC_DEVICE_WIDTH - 60;
            subLabel.viewFrameHeight = 200 / 3;
            subLabel.font = LK_FONT(12);
            subLabel.textColor = LC_RGB(180, 180, 180);
            subLabel.textAlignment = UITextAlignmentRight;
            subLabel.tag = 1003;
            subLabel.numberOfLines = 0;
            configurationCell.ADD(subLabel);
            
            
            UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH - 40;
            line.viewFrameX = 20;
            line.viewFrameY = 200 / 3 - line.viewFrameHeight;
            configurationCell.ADD(line);
        }];
        
        
        LCUIButton * icon = cell.FIND(1001);
        LCUILabel * label = cell.FIND(1002);
        LCUILabel * subLabel = cell.FIND(1003);
        
        NSArray * icons = @[@"SettingBinding.png", @"DeleteCache.png", @"Appstore.png", @"Feedback.png"];
        NSArray * titles = @[LC_LO(@"账号绑定"), LC_LO(@"清除缓存"), LC_LO(@"求鼓励"), @"@CEO"];
        NSArray * subTitles = @[@" ", self.cacheSize ? [NSString stringWithFormat:@"%.2fMB", self.cacheSize] : @" ", @"Backend-关关\niOS-红果果", LC_LO(@"无所不能的王果果")];

        icon.buttonImage = [UIImage imageNamed:icons[indexPath.row - 2] useCache:YES];
        label.text = titles[indexPath.row - 2];
        subLabel.text = subTitles[indexPath.row - 2];

    }
    else{
        
        cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Exit" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            LCUIButton * logoutButton = LCUIButton.view;
            logoutButton.viewFrameX = 50;
            logoutButton.viewFrameY = 50 - 20;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 6) {
        
        return 100;
    }
    
    return 200 / 3;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.nickField resignFirstResponder];
    
    // 更改头像
    if (indexPath.row == 0) {
        
        @weakly(self);
        
        [LKUploadAvatarAndCoverModel chooseAvatorImage:^(NSString *error, UIImage *resultImage) {
         
            @normally(self);
            
            if (!error) {
                
                self.head.image = resultImage;
                [self.fromViewController.userInfoModel getUserInfo:self.fromViewController.user.id];
            }
            else{
                
                [self showTopMessageErrorHud:error];
            }
            
        }];
    }
    // 更改昵称
    else if (indexPath.row == 1){
        
        [self.nickField becomeFirstResponder];
    }
    // 账号绑定
    else if (indexPath.row == 2){
        
        [self.fromViewController.navigationController pushViewController:[LKLinkAccountsViewController viewController] animated:YES];
    }
    // 清除缓存
    else if (indexPath.row == 3) {
        
        [LCUIImageCache.singleton deleteAllImages];
        [self.tableView reloadData];
    }
    // 评价
    else if (indexPath.row == 4){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=975648403&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
    }
    // 反馈
    else if (indexPath.row == 5){
        
        LKInputTextViewController * input = [LKInputTextViewController viewController];
        
        @weakly(self);
        
        input.inputFinished = ^(NSString * string){
            
            @normally(self);
            
            [self uploadFeedback:string];
        };
        
        input.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.fromViewController presentViewController:LC_UINAVIGATION(input) animated:YES completion:nil];
    }
}

-(void) showInViewController:(UIViewController *)viewController
{
    UIView * view = self.FIND(1002);
    view.alpha = 0;
    
    self.blur.viewFrameY = self.viewFrameHeight;
    
    [viewController.view addSubview:self];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        view.alpha = 1;
        
        self.blur.viewFrameY = 64;
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) hide
{
    if (self.willHide) {
        self.willHide();
    }
    
    UIView * view = self.FIND(1002);
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        view.alpha = 0;
        
        self.blur.viewFrameY = self.viewFrameHeight;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

-(void) logout
{
    [self hide];
    
    [LKLocalUser logout];
    [self.fromViewController.navigationController popToRootViewControllerAnimated:YES];
}

-(void) uploadFeedback:(NSString *)feedback
{
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
    return [self folderSizeAtPath:LCUIImageCache.singleton.fileCache.cachePath];
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
