//
//  LKHomeViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHomeViewController.h"
#import "LKHomepageHeader.h"
#import "SquareCashStyleBehaviorDefiner.h"
#import "BLKDelegateSplitter.h"
#import "LKUserCenterViewController.h"
#import "LKHomeTableViewCell.h"
#import "AppDelegate.h"
#import "LKTagsView.h"
#import "LKInputView.h"
#import "LKTagAddModel.h"
#import "LKPostDetailViewController.h"
#import "LKLoginViewController.h"
#import "LKNotificationViewController.h"
#import "LKNotificationCount.h"
#import "SVPullToRefresh.h"
#import "LKUploadAvatarAndCoverModel.h"
#import "LKUserInfoModel.h"
#import "LKPushAnimation.h"
#import "LKTime.h"
#import "LKAssistiveTouchButton.h"
#import "LKSearchViewController.h"
#import "LKNewPostUploadCenter.h"
#import "LKUploadingCell.h"
#import "LCUIKeyBoard.h"

@interface LKHomeViewController () <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

LC_PROPERTY(strong) BLKDelegateSplitter * delegateSplitter;

LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

LC_PROPERTY(strong) LCUIButton * searchButton;
LC_PROPERTY(strong) LCUIButton * notificationButton;

LC_PROPERTY(strong) NSMutableArray * datasource;

LC_PROPERTY(strong) LKInputView * inputView;


LC_PROPERTY(strong) LKUserInfoModel * userInfoModel;

LC_PROPERTY(strong) NSNumber * canResignFirstResponder;

LC_PROPERTY(strong) UIView * fromView;

LC_PROPERTY(copy) NSString * next;


// - - - - - - -
LC_PROPERTY(strong) LKSearchViewController * searchViewController;
LC_PROPERTY(strong) LKNotificationViewController * notificationViewController;


@end

@implementation LKHomeViewController

-(void) dealloc
{
    [self cancelAllRequests];
    [self unobserveAllNotifications];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide status bar.
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    
    // hide navigation bar.
    [self setNavigationBarHidden:YES animated:animated];
    
    // update header.
    [self.header updateWithUser:LKLocalUser.singleton.user];
    
    // show bar.
    [LC_APPDELEGATE.tabBarController showBar];
    
    //
    [LKNotificationCount startCheck];
    
    
    // update user.
    if (LKLocalUser.singleton.isLogin) {
        [self.userInfoModel getUserInfo:LKLocalUser.singleton.user.id];
    }
    
    [self reloadData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.inputView resignFirstResponder];
    
    ((LCUINavigationController *)self.navigationController).animationHandler = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    ((LCUINavigationController *)self.navigationController).animationHandler = ^id(UINavigationControllerOperation operation, UIViewController * fromVC, UIViewController * toVC){
        
        if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[LKPostDetailViewController class]]) {
            
            return [[LKPushAnimation alloc] init];
        }
        
        return nil;
    };
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.canResignFirstResponder = @(YES);
    
    self.userInfoModel = [[LKUserInfoModel alloc] init];
    
    
    [self observeNotification:LKHomeViewControllerAddNewPost];
    [self observeNotification:LKHomeViewControllerUpdateHeader];
    [self observeNotification:LKHomeViewControllerReloadingData];

    
    // read cache...
    NSArray * cache = LKUserDefaults.singleton[self.class.description];

    NSMutableArray * datasource = [NSMutableArray array];
    
    for (NSDictionary * tmp in cache) {
        
        [datasource addObject:[LKPost objectFromDictionary:tmp]];
    }
    
    if (datasource.count) {
        
        self.datasource = datasource;
    }
    
    @weakly(self);
    
    LKNewPostUploadCenter.singleton.addedNewValue = ^(LKPosting * posting, NSNumber * index){
        
        @normally(self);
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index.integerValue inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self performSelector:@selector(scrollViewScrollToTop) withObject:nil afterDelay:0.5];
    };
    
    LKNewPostUploadCenter.singleton.uploadFinished = ^(LKPost * value, NSNumber * index){
        
        @normally(self);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index.integerValue inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        
        if (value) {
         
            [self.datasource insertObject:value atIndex:0];
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
        }
    };
    
    
    LKNewPostUploadCenter.singleton.uploadFailed = ^(id value){
        
        @normally(self);
        
        [self reloadData];
        
        [self showTopMessageErrorHud:LC_LO(@"上传失败啦！请检查您的网络稍后再试Orz～")];
    };
    
    LKNewPostUploadCenter.singleton.stateChanged = ^(id value){
        
        @normally(self);

        [self reloadData];
    };
}

-(void) buildUI
{
    self.tableView = [[LCUITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundViewColor = LC_RGB(245, 240, 236);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.ADD(self.tableView);
    

    @weakly(self);
    
    {
        {
            // Header
            self.header = [[LKHomepageHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 100)];
            self.header.scrollView = self.tableView;
            
            SquareCashStyleBehaviorDefiner *behaviorDefiner = [[SquareCashStyleBehaviorDefiner alloc] init];
            [behaviorDefiner addSnappingPositionProgress:0.0 forProgressRangeStart:0.0 end:0.5];
            [behaviorDefiner addSnappingPositionProgress:1.0 forProgressRangeStart:0.5 end:1.0];
            behaviorDefiner.snappingEnabled = NO;
            behaviorDefiner.elasticMaximumHeightAtTop = NO;
            self.header.behaviorDefiner = behaviorDefiner;
            
            self.delegateSplitter = [[BLKDelegateSplitter alloc] initWithFirstDelegate:behaviorDefiner secondDelegate:self];
            self.tableView.delegate = (id<UITableViewDelegate>)self.delegateSplitter;
            
            [self.view addSubview:self.header];
            
            self.tableView.contentInset = UIEdgeInsetsMake(self.header.maximumBarHeight - 20, 0.0, 0.0, 0.0);
            
            
            //
            self.header.headAction = ^(id value){
                
                @normally(self);
                
                if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
                    
                    [self.navigationController pushViewController:[LKTabBarController hiddenBottomBarWhenPushed:[[LKUserCenterViewController alloc] initWithUser:LKLocalUser.singleton.user]] animated:YES];

                };
            };
            
            self.header.backgroundAction = ^(id value){
                
                // upload cover.
                @normally(self);
                
                if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
                    
                    [LKUploadAvatarAndCoverModel chooseCoverImage:^(NSString *error, UIImage * image) {
                        
                        if (!error) {
                            
                            self.header.backgroundView.image = image;
                            [self.userInfoModel getUserInfo:LKLocalUser.singleton.user.id];
                        }
                    }];
                }
            };
            
            
            self.searchButton = LCUIButton.view;
            self.searchButton.viewFrameWidth = 42;
            self.searchButton.viewFrameHeight = 78 / 3 + 35;
            self.searchButton.viewFrameY = 10;
            self.searchButton.viewFrameX = 4;
            self.searchButton.buttonImage = [UIImage imageNamed:@"SearchIcon.png" useCache:YES];
            self.searchButton.showsTouchWhenHighlighted = YES;
            [self.searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
            [self.header addSubview:self.searchButton];

            
            self.notificationButton = LCUIButton.view;
            self.notificationButton.viewFrameWidth = 44 / 3 + 100 - 8;
            self.notificationButton.viewFrameHeight = 51 / 3 + 100;
            self.notificationButton.viewFrameX = LC_DEVICE_WIDTH - self.notificationButton.viewFrameWidth + 30 - 4;
            self.notificationButton.viewFrameY = - 18;
            self.notificationButton.buttonImage = [UIImage imageNamed:@"NotificationIcon.png" useCache:YES];
            self.notificationButton.showsTouchWhenHighlighted = YES;
            [self.notificationButton addTarget:self action:@selector(notificationAction) forControlEvents:UIControlEventTouchUpInside];
            [self.header addSubview:self.notificationButton];
            
            
            
            //
            [LKNotificationCount bindView:self.notificationButton];
        }
    }
    
    
    //
    self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleFooter];
    self.pullLoader.indicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion){
      
        @normally(self);
        
        [self loadData:diretion];
    };
    
    
    
    self.inputView = LKInputView.view;
    self.inputView.viewFrameY = self.view.viewFrameHeight;
    self.view.ADD(self.inputView);
    
    self.inputView.sendAction = ^(NSString * string){
        
        @normally(self);
        
        if (string.trim.length == 0) {
            
            [self showTopMessageErrorHud:LC_LO(@"标签不能为空")];
            return;
        }
        
        if (string.length > 12) {
            
            [self showTopMessageErrorHud:LC_LO(@"标签长度不能大于12位")];
            return;
        }
        
        LKHomeTableViewCell * cell = (LKHomeTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.inputView.tag inSection:1]];
        
        
        if ([self checkTag:string onTags:((LKPost *)self.inputView.userInfo).tags]) {
            
            [self addTag:string onPost:self.inputView.userInfo onCell:cell];
        }
        else{
            
            [self.view showTopMessageErrorHud:LC_LO(@"该标签已存在")];
            [self.inputView resignFirstResponder];
            self.inputView.textField.text = @"";
        }
    };
    
    self.inputView.didShow = ^(){
      
        @normally(self);
        
        // scroll...
        LKHomeTableViewCell * cell = (LKHomeTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.inputView.tag inSection:1]];
        
//        CGRect originRect = cell.frame;
//        
//
        CGFloat height1 = LC_DEVICE_HEIGHT - cell.viewFrameHeight;
        CGFloat height2 = LCUIKeyBoard.singleton.height + self.inputView.viewFrameHeight - height1;
        
//        CGFloat y = LC_DEVICE_HEIGHT + 20 - self.inputView.viewFrameHeight - LCUIKeyBoard.singleton.height - cell.viewFrameHeight;
//        
//        CGRect rect = [self.view convertRect:CGRectMake(0, y, cell.viewFrameWidth, cell.viewFrameHeight) toView:self.tableView];
        
        //CGRect rect = [cell convertRect:originRect toView:self.view];
        //CGFloat height = (LC_DEVICE_HEIGHT + 64) - (originRect.size.height + self.inputView.viewFrameHeight + LCUIKeyBoard.singleton.height);
        
        [self.tableView setContentOffset:LC_POINT(0, cell.viewFrameY + height2 - 25 + 10) animated:YES];
        
        self.canResignFirstResponder = @(NO);
        [self performSelector:@selector(setCanResignFirstResponder:) withObject:@(YES) afterDelay:1];
    };
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

#pragma mark - 

-(BOOL) checkTag:(NSString *)tag onTags:(NSArray *)onTags
{
    for (LKTag * oTag in onTags) {
        
        if ([oTag.tag isEqualToString:tag]) {
            
            return NO;
        }
    }
    
    return YES;
}

-(void) handleNotification:(NSNotification *)notification
{
    if ([notification is:LKHomeViewControllerAddNewPost]) {
        
        if (notification.object) {
         
            [self.datasource insertObject:notification.object atIndex:0];
            [self reloadData];
            
            [self performSelector:@selector(scrollViewScrollToTop) withObject:nil afterDelay:0.5];
        }
    }
    else if([notification is:LKHomeViewControllerUpdateHeader]){
        
        [self.header updateWithUser:LKLocalUser.singleton.user];
    }
    else if ([notification is:LKHomeViewControllerReloadingData]){
        
        [self loadData:LCUIPullLoaderDiretionTop];
    }
}

-(void) scrollViewScrollToTop
{
    [self.tableView setContentOffset:LC_POINT(0, -self.header.maximumBarHeight) animated:YES];
    [self scrollViewDidScroll:self.tableView];
}

-(void) reloadData
{
    [self.tableView reloadData];
    [self scrollViewDidScroll:self.tableView];
}

#pragma mark -

-(void) addTag:(NSString *)tag onPost:(LKPost *)post onCell:(LKHomeTableViewCell *)cell
{
    @weakly(self);
    
    [self.inputView resignFirstResponder];
    
    [LKTagAddModel addTagString:tag onPost:post requestFinished:^(LKHttpRequestResult *result, NSString *error) {
       
        @normally(self);
        
        if (error) {
            
            [self showTopMessageErrorHud:error];
        }
        else{
            
            // insert...
            LKTag * tag = [LKTag objectFromDictionary:result.json[@"data"]];
            
            if (!tag) {
                
                [self.inputView resignFirstResponder];
                self.inputView.textField.text = @"";
                return;
            }
            
            [post.tags insertObject:tag atIndex:0];
    
            
            // reload tags...
            [cell reloadTags];
            
            
            NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
            
            // reload row...
            if (indexPath) {
                
                post.user.likes = @(post.user.likes.integerValue + 1);
                
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            // input view...
            [self.inputView resignFirstResponder];
            
            //
            self.inputView.textField.text = @"";
            
            [self scrollViewDidScroll:self.tableView];
        }
        
    }];
}

-(void) loadData:(LCUIPullLoaderDiretion)diretion
{
    
    if (LC_APPDELEGATE.tabBarController.loading) {
        
        [self.pullLoader endRefresh];
        return;
    }
    
    LC_APPDELEGATE.tabBarController.loading = YES;
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"homefeeds"].AUTO_SESSION();
    
    if (!LC_NSSTRING_IS_INVALID(self.next) && diretion == LCUIPullLoaderDiretionBottom) {
        
        [interface addParameter:self.next key:@"ts"];
    }
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            
            self.next = result.json[@"data"][@"next"] ? result.json[@"data"][@"next"] : @"";

            
            NSArray * resultData = result.json[@"data"][@"posts"];
            NSMutableArray * datasource = [NSMutableArray array];
            
            for (NSDictionary * tmp in resultData) {
                
                [datasource addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (diretion == LCUIPullLoaderDiretionTop) {
                
                // save cache...
                LKUserDefaults.singleton[self.class.description] = resultData;
                
                self.datasource = datasource;
            }
            else{
                
                [self.datasource addObjectsFromArray:datasource];
            }
            
            [self.pullLoader endRefresh];
            [self reloadData];
            
            LC_APPDELEGATE.tabBarController.loading = NO;
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self.pullLoader endRefresh];
            [self showTopMessageErrorHud:result.error];
            
            LC_APPDELEGATE.tabBarController.loading = NO;
        }
    }];

}

-(void) searchAction
{
    [self.inputView resignFirstResponder];
    
    if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
        
        LC_FAST_ANIMATIONS_F(0.2, ^{
            
            self.searchButton.alpha = 0;
            self.notificationButton.alpha = 0;
            self.header.headImageView.alpha = 0;
            self.header.nameLabel.alpha = 0;
            LC_APPDELEGATE.tabBarController.assistiveTouchButton.hidden = YES;
            
        }, ^(BOOL finished){
            
            LKSearchViewController * view = LKSearchViewController.view;
            
            self.searchViewController = view;
            
            [view showInViewController:self];
            
            @weakly(self);
            
            view.willHide = ^(){
                
                @normally(self);
                
                [UIView animateWithDuration:0.2 delay:0.25 options:UIViewAnimationOptionCurveLinear animations:^{
                    
                    self.searchButton.alpha = 1;
                    self.notificationButton.alpha = 1;
                    [self.header layoutSubviews];
                    LC_APPDELEGATE.tabBarController.assistiveTouchButton.hidden = NO;
                    
                } completion:^(BOOL finished) {
                    
                    self.searchViewController = nil;
                }];

            };

        });
        
    }

}

-(void) notificationAction
{
    if (!self.isCurrentDisplayController) {
        return;
    }
    
    if (self.searchViewController) {
        [self.searchViewController hide];
    }
    
    [self.inputView resignFirstResponder];

    if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
        
        LC_FAST_ANIMATIONS_F(0.2, ^{
            
            self.searchButton.alpha = 0;
            self.header.headImageView.alpha = 0;
            self.header.nameLabel.alpha = 0;
            LC_APPDELEGATE.tabBarController.assistiveTouchButton.hidden = YES;
            
        }, ^(BOOL finished){
        
            LKNotificationViewController * view = LKNotificationViewController.view;
            
            [view showInViewController:self];
            
            @weakly(self);
            
            view.willHide = ^(){
                
                @normally(self);
                
                [UIView animateWithDuration:0.2 delay:0.25 options:UIViewAnimationOptionCurveLinear animations:^{
                    
                    self.searchButton.alpha = 1;
                    self.notificationButton.alpha = 1;
                    [self.header layoutSubviews];
                    LC_APPDELEGATE.tabBarController.assistiveTouchButton.hidden = NO;
                    
                } completion:^(BOOL finished) {
                    
                }];
            };
        });
    }
}

#pragma mark -

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal)
{
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
    
    [LC_APPDELEGATE.tabBarController hideBar];
}

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal)
{
    if (self.inputView.isFirstResponder) {
        
        [self.inputView resignFirstResponder];
        return;
    }
    
    self.fromView = signal.from;
    
    LKPostDetailViewController * detail = [[LKPostDetailViewController alloc] initWithPost:signal.object];
    
    [self.navigationController pushViewController:[LKTabBarController hiddenBottomBarWhenPushed:detail] animated:YES];
    
    LKPost * post = signal.object;
    
    if ([post.tagString rangeOfString:@"Comment-"].length) {
        
        LKTag * tag = [[LKTag alloc] init];
        tag.id = @([post.tagString stringByReplacingOccurrencesOfString:@"Comment-" withString:@""].integerValue);
        
        [detail performSelector:@selector(openCommentsView:) withObject:tag afterDelay:0.35];
    }
}

LC_HANDLE_UI_SIGNAL(LKUploadingCellCancel, signal)
{
    [LKNewPostUploadCenter.singleton cancelPosting:signal.object];
}

LC_HANDLE_UI_SIGNAL(LKUploadingCellReupload, signal)
{
    [LKNewPostUploadCenter.singleton reuploadPosting:signal.object];
}

#pragma mark -

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return LKNewPostUploadCenter.singleton.uploadingImages.count;
    }
    else{
        
        return self.datasource.count;
    }
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        LKUploadingCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Upload" andClass:[LKUploadingCell class]];
        
        cell.posting = LKNewPostUploadCenter.singleton.uploadingImages[indexPath.row];
                
        return cell;
    }
    
    LKHomeTableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Content" andClass:[LKHomeTableViewCell class]];

    LKPost * post = self.datasource[indexPath.row];
    
    cell.post = post;
    cell.tableView = self.tableView;
    
    @weakly(self);
    
    cell.addTag = ^(LKPost * value){
      
        @normally(self);
        
        if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
            
            self.inputView.userInfo = value;
            self.inputView.tag = indexPath.row;
            
            [self.inputView becomeFirstResponder];
        }
    };
    
    cell.removedTag = ^(LKPost * value){
        
        @normally(self);

        [self.tableView beginUpdates];
        [self reloadData];
        [self.tableView endUpdates];
    };
    
    [cell cellOnTableView:self.tableView didScrollOnView:self.view];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return 38;
    }
    
    return [LKHomeTableViewCell height:self.datasource[indexPath.row]];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.header handleScrollDidScroll:scrollView];
    
    
    if (scrollView.contentOffset.y < -280) {
        
        [self loadData:LCUIPullLoaderDiretionTop];
    }
    
    if (self.canResignFirstResponder.boolValue) {
        
        [self.inputView resignFirstResponder];
    }
    
//    // Get visible cells on table view.
//    NSArray *visibleCells = [self.tableView visibleCells];
//    
//    for (LKHomeTableViewCell * cell in visibleCells) {
//        
//        [cell cellOnTableView:self.tableView didScrollOnView:self.view];
//    }
}

@end
