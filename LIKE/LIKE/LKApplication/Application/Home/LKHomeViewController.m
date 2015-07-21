//
//  LKHomeViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/13.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKHomeViewController.h"
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
#import "LKHomeHeader.h"
#import "LKSearchBar.h"
#import "FXBlurView.h"
#import "LKAttentionViewController.h"
#import "Doppelganger.h"

#define FOCUS_FEED_CACHE_KEY [NSString stringWithFormat:@"LKFocusFeedKey-%@", LKLocalUser.singleton.user.id]

typedef NS_ENUM(NSInteger, LKHomepageFeedType)
{
    LKHomepageFeedTypeMain,
    LKHomepageFeedTypeFocus,
    LKHomepageFeedTypeNotification,
};

@interface LKHomeViewController () <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

LC_PROPERTY(assign) LKHomepageFeedType feedType;

LC_PROPERTY(strong) LKHomeHeader * header;

LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;

LC_PROPERTY(strong) LKInputView * inputView;


LC_PROPERTY(strong) LKUserInfoModel * userInfoModel;

LC_PROPERTY(strong) NSNumber * canResignFirstResponder;

LC_PROPERTY(strong) UIView * fromView;

LC_PROPERTY(copy) NSString * next;
LC_PROPERTY(copy) NSNumber * focusNext;


// - - - - - - -
LC_PROPERTY(strong) LKSearchViewController * searchViewController;
LC_PROPERTY(strong) LKNotificationViewController * notificationViewController;
LC_PROPERTY(strong) LKAttentionViewController * attentionViewController;


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
    if (self.searchViewController) {
        
        [self setNavigationBarHidden:YES animated:animated];
    }
    else{
        
        [self setNavigationBarHidden:NO animated:animated];
    }
    
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
    
    
    NSArray * focusCache = LKUserDefaults.singleton[FOCUS_FEED_CACHE_KEY];
    
    NSMutableArray * focusDatasource = [NSMutableArray array];
    
    for (NSDictionary * tmp in focusCache) {
        
        [focusDatasource addObject:[LKPost objectFromDictionary:tmp]];
    }
    
    if (focusDatasource.count) {
        
        self.focusDatasource = datasource;
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
    self.view.backgroundColor = LKColor.backgroundColor;
    
    // Bar item.
    [self setNavigationBarButton:LCUINavigationBarButtonTypeRight image:[[UIImage imageNamed:@"NotificationIcon.png" useCache:YES] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]] selectImage:nil];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[[UIImage imageNamed:@"CollectionIcon.png"] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]] selectImage:nil];
    
    
    // Bind badge.
    [LKNotificationCount bindView:self.navigationItem.rightBarButtonItem.customView];


    //
    self.titleView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"HomeLikeIcon.png" useCache:YES]];
    
    //
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];

        
    //
    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.viewFrameWidth, self.view.viewFrameHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundViewColor = LC_RGB(245, 240, 236);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.ADD(self.tableView);
    

    @weakly(self);
    
    
    self.header = [[LKHomeHeader alloc] initWithCGSize:CGSizeMake(LC_DEVICE_WIDTH, 150)];
    
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
    
    self.header.willBeginSearch = ^(id value){
      
        @normally(self);
        
        [self searchAction];
        
        self.tableView.scrollEnabled = NO;
    };
    
    self.header.willEndSearch = ^(id value){
      
        @normally(self);
        
        [self setNavigationBarHidden:NO animated:YES];
        
        LC_FAST_ANIMATIONS(0.25, ^{
            
            self.tableView.contentOffset = CGPointMake(0, 0);
            
        });
        
        LC_APPDELEGATE.tabBarController.assistiveTouchButton.hidden = NO;

        LC_FAST_ANIMATIONS_F(0.25, ^{
            
            self.searchViewController.alpha = 0;
            self.tableView.viewFrameHeight -= 64;

        }, ^(BOOL finished){
            
            [self.searchViewController removeFromSuperview];
            self.searchViewController = nil;
            
        });
        
        self.tableView.scrollEnabled = YES;
    };
    
    self.tableView.tableHeaderView = self.header;


    
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
        
        CGFloat height1 = LC_DEVICE_HEIGHT - cell.viewFrameHeight;
        CGFloat height2 = LCUIKeyBoard.singleton.height + self.inputView.viewFrameHeight - height1;
        
        [self.tableView setContentOffset:LC_POINT(0, cell.viewFrameY + height2 - 25 + 10 + 63) animated:YES];
        
        self.canResignFirstResponder = @(NO);
        [self performSelector:@selector(setCanResignFirstResponder:) withObject:@(YES) afterDelay:1];
    };
    
    [self loadData:LCUIPullLoaderDiretionTop];
}

#pragma mark - 

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    if (type == LCUINavigationBarButtonTypeLeft) {
        
        if (self.feedType == LKHomepageFeedTypeMain) {
            
            if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){

                self.feedType = LKHomepageFeedTypeFocus;
                
            }
        }
        else{

            if (self.feedType == LKHomepageFeedTypeFocus) {
                
                LC_APPDELEGATE.tabBarController.loading = NO;
                [self cancelAllRequests];
                
                self.feedType = LKHomepageFeedTypeMain;

                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            }
            else{
             
                self.feedType = LKHomepageFeedTypeMain;

            }
        }
        
    }
    else if (type == LCUINavigationBarButtonTypeRight) {
        
        [self notificationAction];
    }
}

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
    [self.tableView setContentOffset:LC_POINT(0, 0) animated:YES];
}

-(void) reloadData
{
    [self.tableView reloadData];
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
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:self.feedType == LKHomepageFeedTypeFocus ? @"friendfeeds" : @"homefeeds" ].AUTO_SESSION();
    
    if (self.feedType == LKHomepageFeedTypeFocus) {
        
        if (self.focusNext && diretion == LCUIPullLoaderDiretionBottom) {
            
            [interface addParameter:self.focusNext key:@"ts"];
        }
    }
    else{
        
        if (!LC_NSSTRING_IS_INVALID(self.next) && diretion == LCUIPullLoaderDiretionBottom) {
            
            [interface addParameter:self.next key:@"ts"];
        }
    }
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            if (self.feedType == LKHomepageFeedTypeFocus) {
                
                self.focusNext = result.json[@"data"][@"next"] ? result.json[@"data"][@"next"] : nil;
            }
            else{
                
                self.next = result.json[@"data"][@"next"] ? result.json[@"data"][@"next"] : @"";
            }
            
            NSArray * resultData = result.json[@"data"][@"posts"];
            NSMutableArray * datasource = [NSMutableArray array];
            
            for (NSDictionary * tmp in resultData) {
                
                [datasource addObject:[LKPost objectFromDictionary:tmp]];
            }
            
            if (diretion == LCUIPullLoaderDiretionTop) {
                
                
                // Change datasource and save cache...
                if (self.feedType == LKHomepageFeedTypeFocus) {
                    
                    self.focusDatasource = datasource;
                    LKUserDefaults.singleton[FOCUS_FEED_CACHE_KEY] = resultData;

                }
                else{
                    
                    self.datasource = datasource;
                    LKUserDefaults.singleton[self.class.description] = resultData;
                }
                
            }
            else{
                
                if (self.feedType == LKHomepageFeedTypeFocus) {

                    [self.focusDatasource addObjectsFromArray:datasource];
                }
                else{

                    [self.datasource addObjectsFromArray:datasource];
                }
            }
            
            if (diretion == LCUIPullLoaderDiretionBottom) {
                
                [self.pullLoader endRefresh];
            }
            
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


-(void) setFeedType:(LKHomepageFeedType)feedType
{
    _feedType = feedType;
    
    LCUIButton * left = (LCUIButton *)self.navigationItem.leftBarButtonItem.customView;
    LCUIButton * right = (LCUIButton *)self.navigationItem.rightBarButtonItem.customView;
    UIView * title = self.titleView;
    
    if (feedType == LKHomepageFeedTypeMain) {
        
        LC_FAST_ANIMATIONS_F(0.25, ^{
           
            left.alpha = 0;
            right.alpha = 0;
            title.alpha = 0;
            self.notificationViewController.alpha = 0;
            
        }, ^(BOOL finished){
            
            [self.notificationViewController removeFromSuperview];
            self.notificationViewController = nil;
            
            UIImage * leftImage = [[UIImage imageNamed:@"CollectionIcon.png"] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
            UIImage * rightImage = [[UIImage imageNamed:@"NotificationIcon.png" useCache:YES] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
            
            left.buttonImage = leftImage;
            right.buttonImage = rightImage;
            
            self.titleView = [LCUIImageView viewWithImage:[UIImage imageNamed:@"HomeLikeIcon.png" useCache:YES]];
            self.titleView.alpha = 0;
            
            LC_FAST_ANIMATIONS(0.25, ^{
               
                left.alpha = 1;
                right.alpha = 1;
                self.tableView.alpha = 1;
                self.titleView.alpha = 1;
                
            });

        });
    }
    else if (feedType == LKHomepageFeedTypeNotification){
      
        LKNotificationViewController * notification = LKNotificationViewController.view;
        notification.alpha = 0;
        self.view.ADD(notification);
        
        self.notificationViewController = notification;
        
        LC_FAST_ANIMATIONS_F(0.25, ^{
            
            left.alpha = 0;
            right.alpha = 0;
            title.alpha = 0;
            self.tableView.alpha = 0;
            
        }, ^(BOOL finished){
            
            UIImage * leftImage = [[UIImage imageNamed:@"NavigationBarDismiss.png" useCache:YES] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
            
            left.buttonImage = leftImage;
            
            LCUILabel * header = LCUILabel.view;
            header.frame = CGRectMake(0, 0, 200, 44);
            header.textAlignment = UITextAlignmentCenter;
            header.font = LK_FONT_B(16);
            header.textColor = [UIColor whiteColor];
            header.text = LC_LO(@"通知");
            self.titleView = header;
            self.titleView.alpha = 0;

            LC_FAST_ANIMATIONS(0.25, ^{
                
                left.alpha = 1;
                notification.alpha = 1;
                self.titleView.alpha = 1;
            });
        });
    }
    else if (feedType == LKHomepageFeedTypeFocus){
      
        LC_APPDELEGATE.tabBarController.loading = NO;
        [self cancelAllRequests];
        
        [self loadData:LCUIPullLoaderDiretionTop];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            left.alpha = 0;
            //right.alpha = 0;
            title.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];

            UIImage * leftImage = [[UIImage imageNamed:@"CollectionIcon.png"] imageWithTintColor:[UIColor whiteColor]];
            
            left.buttonImage = leftImage;
            
            LCUILabel * header = LCUILabel.view;
            header.frame = CGRectMake(0, 0, 200, 44);
            header.textAlignment = UITextAlignmentCenter;
            header.font = LK_FONT_B(16);
            header.textColor = [UIColor whiteColor];
            header.text = LC_LO(@"关注的人");
            self.titleView = header;
            self.titleView.alpha = 0;

            [UIView animateWithDuration:0.25 animations:^{
                
                left.alpha = 1;
                self.titleView.alpha = 1;
            }];
        }];
    };
}


-(void) searchAction
{
    [self.inputView resignFirstResponder];
    
    if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
        
        [self setNavigationBarHidden:YES animated:YES];
        
        LC_FAST_ANIMATIONS(0.25, ^{
            
            self.tableView.contentOffset = CGPointMake(0, (self.header.viewFrameHeight - 35) - 20 - 10);
            
        });
        
        LC_APPDELEGATE.tabBarController.assistiveTouchButton.hidden = YES;

        LKSearchViewController * view = LKSearchViewController.view;
        
        self.header.searchViewController = view;
        self.searchViewController = view;
        self.tableView.viewFrameHeight += 64;
        
        view.viewFrameY = self.header.viewBottomY;
        view.alpha = 0;
        
        self.tableView.ADD(view);
        
        LC_FAST_ANIMATIONS(0.5, ^{
           
            view.alpha = 1;
        });
        
        view.willHide = ^(id value){
            
        };
        
    }

}

-(void) notificationAction
{
    if (!self.isCurrentDisplayController) {
        return;
    }
    
    [self.inputView resignFirstResponder];

    if(![LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
        
        self.feedType = LKHomepageFeedTypeNotification;
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
    
    LCUINavigationController * nav = LC_UINAVIGATION(detail);
    
    [detail setPresendModelAnimationOpen];

    [self.navigationController presentViewController:nav animated:YES completion:nil];

    
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
        
        if (self.feedType == LKHomepageFeedTypeFocus) {
            
            return self.focusDatasource.count;
        }
        
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

    LKPost * post = nil;
    
    if (self.feedType == LKHomepageFeedTypeFocus) {
        
        post = self.focusDatasource[indexPath.row];
    }
    else{
        
        post = self.datasource[indexPath.row];
    }
    
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
    
    if (self.feedType == LKHomepageFeedTypeFocus) {
        
        return [LKHomeTableViewCell height:self.focusDatasource[indexPath.row]];
    }
    else{
    
        return [LKHomeTableViewCell height:self.datasource[indexPath.row]];
    }
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.header layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
    
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        
        if (scrollView.contentOffset.y < -80) {
            
            [self loadData:LCUIPullLoaderDiretionTop];
        }
    }
}

@end
