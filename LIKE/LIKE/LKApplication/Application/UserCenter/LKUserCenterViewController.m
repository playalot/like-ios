//
//  LKUserCenterViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/15.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKUserCenterViewController.h"
#import "LKHomepageHeader.h"
#import "SquareCashStyleBehaviorDefiner.h"
#import "BLKDelegateSplitter.h"
#import "LKUserCenterModel.h"
#import "LKUserCenterPhotoCell.h"
#import "LKUserInfoModel.h"
#import "LKUserCenterUserCell.h"
#import "LKUploadAvatarAndCoverModel.h"
#import "LKInputView.h"
#import "LKModifyUserInfoModel.h"
#import "LKFriendshipModel.h"
#import "LKPostDetailViewController.h"
#import "LKSettingsViewController.h"
#import "LKLoginViewController.h"
#import "LKUserInfoCache.h"
#import "JTSImageViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface LKUserCenterViewController () <UITableViewDataSource, UITableViewDelegate, LKPostDetailViewControllerCancelFavorDelegate>

//
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LKHomepageHeader * header;
LC_PROPERTY(strong) BLKDelegateSplitter * delegateSplitter;

LC_PROPERTY(strong) LCUIButton * friendshipButton;

LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(strong) LCUIActivityIndicatorView * loadingActivity;
//
LC_PROPERTY(strong) LKUserCenterModel * userCenterModel;

LC_PROPERTY(assign) LKUserCenterModelType currentType;

LC_PROPERTY(assign) BOOL isLocalUser;

@end

@implementation LKUserCenterViewController

-(void) dealloc
{
    self.tableView.delegate = nil;
    [self unobserveAllNotifications];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.header updateWithUser:self.user];
    
    [self setNavigationBarHidden:YES animated:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    
    
    if (self.tableView.viewFrameY != 0) {
        
        self.tableView.pop_springBounciness = 10;
        self.tableView.pop_springSpeed = 10;
        self.tableView.pop_spring.center = LC_POINT(self.tableView.viewCenterX, self.tableView.viewCenterY - 30);
        self.tableView.pop_spring.alpha = 1;
    }
}

+(LKUserCenterViewController *) pushUserCenterWithUser:(LKUser *)user navigationController:(UINavigationController *)navigationController
{
    LKUserCenterViewController * userCenter = [[LKUserCenterViewController alloc] initWithUser:user];

    [navigationController pushViewController:userCenter animated:YES];
    
    return userCenter;
}

-(instancetype) initWithUser:(LKUser *)user
{
    if (self = [super init]) {
        
        self.user = user;
        
        self.isLocalUser = self.user.id.integerValue == LKLocalUser.singleton.user.id.integerValue;
        
        LKUser * cache = LKUserInfoCache.singleton[self.user.id.description];
        
        if (!self.isLocalUser && cache) {
            
            self.user = cache;
        }
    }
    
    return self;
}

-(void) viewDidLoad
{
    if (self.isLocalUser) {
        
        [self observeNotification:LKUserCenterViewControllerReloadingData];
    }
    
    
    self.userCenterModel = [[LKUserCenterModel alloc] init];
    self.userInfoModel = [[LKUserInfoModel alloc] init];
    
    @weakly(self);
    
    self.userInfoModel.requestFinished = ^(LKHttpRequestResult * result, NSString * error){
     
        @normally(self);
        
        if (!error){
            
            self.user = self.userInfoModel.user;
            [self.header updateWithUser:self.userInfoModel.user];
            
            LKSegmentHeader * tableViewHeader = (LKSegmentHeader *)self.tableView.tableHeaderView;
            
            [tableViewHeader setTitle:LC_NSSTRING_FORMAT(@"%@",self.userInfoModel.user.postCount) subTitle:LC_LO(@"照片") atIndex:0];
            [tableViewHeader setTitle:LC_NSSTRING_FORMAT(@"%@",self.userInfoModel.user.followCount) subTitle:LC_LO(@"关注") atIndex:1];
            [tableViewHeader setTitle:LC_NSSTRING_FORMAT(@"%@",self.userInfoModel.user.fansCount) subTitle:LC_LO(@"粉丝") atIndex:2];
            
            if (self.isLocalUser) {
                
                [tableViewHeader setTitle:LC_NSSTRING_FORMAT(@"%@",self.userInfoModel.user.favorCount) subTitle:LC_LO(@"收藏") atIndex:3];
            }
            
            [self updateFriendButton];

        }
    };
    
    [self.userInfoModel getUserInfo:self.user.id];
    
    [super viewDidLoad];
}

-(void) buildUI
{
    self.tableView = [[LCUITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.viewFrameY = 30;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundViewColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alpha = 0;
    self.view.ADD(self.tableView);
    
    
    {
        {
            // Navigation bar.
            self.header = [[LKHomepageHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 100.0)];
            self.header.scrollView = self.tableView;
            [self.header.maskView removeFromSuperview];
            self.header.maskView = nil;
            
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
            
            self.header.icon.image = nil;
            self.header.nameLabelOnShowing.hidden = NO;
            self.header.backgroundView.backgroundColor = LC_RGB(245, 240, 236);
            
            //
            @weakly(self);
            
            self.header.headAction = ^(UIImageView * imageView){
                
                @normally(self);

                JTSImageInfo * info = [[JTSImageInfo alloc] init];
                
                if (LC_NSSTRING_IS_INVALID(self.user.originAvatar)) {
                    
                    info.imageURL = [NSURL URLWithString:self.user.avatar];
                }
                else{
                    
                    info.imageURL = [NSURL URLWithString:self.user.originAvatar];
                }
                
                info.referenceRect = imageView.frame;
                info.referenceView = imageView.superview;
                info.referenceCornerRadius = 65 / 2;
                
                // Setup view controller
                JTSImageViewController * imageViewer = [[JTSImageViewController alloc]
                                                       initWithImageInfo:info
                                                       mode:JTSImageViewControllerMode_Image
                                                       backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
                // Present the view controller.
                [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
            };
            
            
            self.header.backgroundAction = ^(id value){
              
                // upload cover.
                @normally(self);

                if (self.isLocalUser) {
                 
                    [LKUploadAvatarAndCoverModel chooseCoverImage:^(NSString *error, UIImage * image) {
                        
                        if (!error) {
                            
                            self.header.backgroundView.image = image;
                            [self.userInfoModel getUserInfo:self.user.id];
                        }
                    }];
                }
            };
            
            self.header.labelAction = ^(id value){
              
                // .
//                @normally(self);
//
//                if (self.isLocalUser) {
//                    
//                    [self.inputView becomeFirstResponder];
//                }
            };
            
            
            // shadow...
//            UIView * shadow = UIView.VIEW.WIDTH(LC_DEVICE_WIDTH).HEIGHT(200).COLOR([[UIColor blackColor] colorWithAlphaComponent:0.22]);
//            [self.header insertSubview:shadow aboveSubview:self.header.backgroundImageView];
            
            
            //
            LCUIButton * backButton = LCUIButton.view;
            backButton.viewFrameWidth = 50;
            backButton.viewFrameHeight = 54 / 3 + 40;
            backButton.viewFrameY = 10;
            backButton.buttonImage = [UIImage imageNamed:@"NavigationBarBack.png" useCache:YES];
            backButton.showsTouchWhenHighlighted = YES;
            [backButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
            backButton.tag = 1002;
            [self.header addSubview:backButton];
            
            
            if (self.isLocalUser) {
             
                LCUIButton * setButton = LCUIButton.view;
                setButton.viewFrameWidth = 64 / 3 + 40;
                setButton.viewFrameHeight = 64 / 3 + 40;
                setButton.viewFrameX = LC_DEVICE_WIDTH - setButton.viewFrameWidth;
                setButton.viewFrameY = 10;
                setButton.buttonImage = [UIImage imageNamed:@"NavigationBarSet.png" useCache:YES];
                setButton.showsTouchWhenHighlighted = YES;
                [setButton addTarget:self action:@selector(setAction) forControlEvents:UIControlEventTouchUpInside];
                [self.header addSubview:setButton];
            }
            else{
                
                self.friendshipButton = LCUIButton.view;
                self.friendshipButton.viewFrameWidth = 64 / 3 + 40;
                self.friendshipButton.viewFrameHeight = 64 / 3 + 40;
                self.friendshipButton.viewFrameX = LC_DEVICE_WIDTH - self.friendshipButton.viewFrameWidth;
                self.friendshipButton.viewFrameY = 10;
                self.friendshipButton.showsTouchWhenHighlighted = YES;
                [self.friendshipButton addTarget:self action:@selector(friendShipAction) forControlEvents:UIControlEventTouchUpInside];
                [self.header addSubview:self.friendshipButton];
                
                
                self.loadingActivity = [LCUIActivityIndicatorView whiteView];
                self.loadingActivity.center = self.friendshipButton.center;
                [self.header addSubview:self.loadingActivity];
                
                // update...
                [self updateFriendButton];
            }
        }
    }
    
    // Header.
    LKSegmentHeader * tableViewHeader = LKSegmentHeader.view;
    tableViewHeader.viewFrameWidth = LC_DEVICE_WIDTH;
    tableViewHeader.viewFrameHeight = 52;
    
    [tableViewHeader addTitle:[NSString stringWithFormat:@"%@", @(self.user.postCount.integerValue)] subTitle:LC_LO(@"照片")];
    [tableViewHeader addTitle:[NSString stringWithFormat:@"%@", @(self.user.followCount.integerValue)] subTitle:LC_LO(@"关注")];
    [tableViewHeader addTitle:[NSString stringWithFormat:@"%@", @(self.user.fansCount.integerValue)] subTitle:LC_LO(@"粉丝")];
    
    if (self.isLocalUser) {

        [tableViewHeader addTitle:[NSString stringWithFormat:@"%@", @(self.user.favorCount.integerValue)] subTitle:LC_LO(@"收藏")];
    }

    
    @weakly(self);
    
    tableViewHeader.didSelected = ^(NSInteger index){
        
        @normally(self);
        
        self.currentType = index;
    };
    
    
    self.tableView.tableHeaderView = tableViewHeader;
    
    
    //
    self.pullLoader = [[LCUIPullLoader alloc] initWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleFooter];
    
    self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion){
      
        @normally(self);
        
        [self loadMore];
    };
    
    
    self.inputView = LKInputView.view;
    self.inputView.viewFrameY = self.view.viewFrameHeight;
    self.inputView.textField.placeholder = LC_LO(@"输入新昵称");
    self.view.ADD(self.inputView);
    
    self.inputView.sendAction = ^(NSString * string){
        
        @normally(self);
        
        [self.inputView resignFirstResponder];
        
        [LKModifyUserInfoModel setNewName:string requestFinished:^(NSString *error) {
           
            if (!error) {
                
                [self.userInfoModel getUserInfo:self.user.id];
            }
        }];
    };
    
    
    self.currentType = LKUserCenterModelTypePhotos;

    [self.userCenterModel getDataAtFirstPage:YES type:LKUserCenterModelTypeFocus uid:self.user.id];
    [self.userCenterModel getDataAtFirstPage:YES type:LKUserCenterModelTypeFans uid:self.user.id];
    [self.userCenterModel getDataAtFirstPage:YES type:LKUserCenterModelTypeFavor uid:self.user.id];
    
}

#pragma mark - 

-(void) handleNotification:(NSNotification *)notification
{
    if ([notification is:LKUserCenterViewControllerReloadingData]) {
        
        [self loadData:self.currentType diretion:LCUIPullLoaderDiretionTop];
    }
}

#pragma mark -

-(void) loadMore
{
    [self loadData:self.currentType diretion:LCUIPullLoaderDiretionBottom];
}

-(void) dismissAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) setAction
{
    LC_FAST_ANIMATIONS(0.25, ^{
        
        ((UIView *)self.header.FIND(1002)).alpha = 0;
        self.header.headImageView.alpha = 0;
        
    });

    
    LKSettingsViewController * settings = LKSettingsViewController.view;
    [settings showInViewController:self];
    
    @weakly(self);
    
    settings.willHide = ^(){
      
        @normally(self);
        
        LC_FAST_ANIMATIONS(0.25, ^{
            
            self.header.headImageView.alpha = 1;
            ((UIView *)self.header.FIND(1002)).alpha = 1;
            [self scrollViewDidScroll:self.tableView];
            
        });
        
    };
    
    settings.fromViewController = self;
}

-(void) friendShipAction
{
    if([LKLoginViewController needLoginOnViewController:[LCUIApplication sharedInstance].window.rootViewController]){
        
        return;
    }
    
    LC_FAST_ANIMATIONS(0.15, ^{
        
        self.friendshipButton.alpha = 0;
        [self.loadingActivity startAnimating];
    });
    
    [LKFriendshipModel friendshipAction:self.user requestFinished:^(NSNumber *newFriendship, NSString *error) {
        
        [self updateFriendButton];
        [self updateUserCache];
        
        LC_FAST_ANIMATIONS(0.15, ^{
            
            self.friendshipButton.alpha = 1;
            [self.loadingActivity stopAnimating];
        });
    }];
}

-(void) updateFriendButton
{
    switch (self.user.isFollowing.integerValue) {
            
        case 0:
            self.friendshipButton.buttonImage = [UIImage imageNamed:@"FocusWirte.png" useCache:YES];
            break;
            
        case 1:
            self.friendshipButton.buttonImage = [UIImage imageNamed:@"AlreadyFocusWrite.png" useCache:YES];
            break;
            
        case 2:
            self.friendshipButton.buttonImage = [UIImage imageNamed:@"EachOtherFocusWrite.png" useCache:YES];
            break;
    }
}

-(void) updateUserCache
{
    [self.userInfoModel.rawUserInfo setObject:self.userInfoModel.user.isFollowing forKey:@"is_following"];
    LKUserInfoCache.singleton[self.user.id.description] = self.userInfoModel.rawUserInfo;
}

#pragma mark -

-(void) setCurrentType:(LKUserCenterModelType)currentType
{
    _currentType = currentType;
    
    self.pullLoader.canLoadMore = [self.userCenterModel canLoadMoreWithType:currentType];
    
    [self loadData:currentType diretion:LCUIPullLoaderDiretionTop];
}

-(void) loadData:(LKUserCenterModelType)type diretion:(LCUIPullLoaderDiretion)diretion
{
    [self.tableView reloadData];

    [self.userCenterModel getDataAtFirstPage:diretion == LCUIPullLoaderDiretionTop type:type uid:self.user.id];
    
    @weakly(self);
    
    self.userCenterModel.requestFinished = ^(LKUserCenterModelType type, LKHttpRequestResult * result, NSString * error){
     
        @normally(self);
        
        [self.pullLoader endRefresh];
        [self.tableView reloadData];
        
        if (error) {
            
            [self showTopMessageErrorHud:error];;
        }
        
        self.pullLoader.canLoadMore = [self.userCenterModel canLoadMoreWithType:type];
    };
}

#pragma mark -

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal)
{
    LKPost * post = signal.object;
    if (self.currentType == LKUserCenterModelTypePhotos) {
        
        post.user = self.user;
    }
    
    LKPostDetailViewController * postDetail = [[LKPostDetailViewController alloc] initWithPost:post];
    postDetail.cancelFavordelegate = self;
    
    LCUINavigationController * nav = LC_UINAVIGATION(postDetail);
    
    [postDetail setPresendModelAnimationOpen];

    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentType == LKUserCenterModelTypePhotos || self.currentType == LKUserCenterModelTypeFavor) {
        
        NSArray * datasource = [self.userCenterModel dataWithType:self.currentType];
        
        NSInteger remainder = datasource.count % 3;
        
        return remainder ? datasource.count / 3 + 1 : datasource.count / 3;
    }
    else{
        
        return [self.userCenterModel dataWithType:self.currentType].count;
    }
    
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentType == LKUserCenterModelTypePhotos) {
        
        LKUserCenterPhotoCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Photos" andClass:[LKUserCenterPhotoCell class]];

        NSInteger index = indexPath.row * 3;
        
        NSArray * datasource = [self.userCenterModel dataWithType:LKUserCenterModelTypePhotos];
        
        LKPost * post = datasource[index];
        LKPost * post1 = index + 1 < datasource.count ? datasource[index + 1] : nil;
        LKPost * post2 = index + 2 < datasource.count ? datasource[index + 2] : nil;

        NSMutableArray * array = [NSMutableArray array];
        
        if (post) {
            [array addObject:post];
        }
        
        if (post1) {
            [array addObject:post1];
        }
        
        if (post2) {
            [array addObject:post2];
        }
        
        cell.posts = array;
        
        return cell;
        
    } else if (self.currentType == LKUserCenterModelTypeFocus){
        
        LKUserCenterUserCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Focus" andClass:[LKUserCenterUserCell class]];

        cell.user = self.userCenterModel.focusArray[indexPath.row];
        
        return cell;
        
    } else if (self.currentType == LKUserCenterModelTypeFans){
     
        LKUserCenterUserCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Fans" andClass:[LKUserCenterUserCell class]];

        cell.user = self.userCenterModel.fansArray[indexPath.row];
        
        return cell;
        
    } else if (self.currentType == LKUserCenterModelTypeFavor) {
        
        LKUserCenterPhotoCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Favor" andClass:[LKUserCenterPhotoCell class]];
        
        NSInteger index = indexPath.row * 3;
        
        NSArray * datasource = [self.userCenterModel dataWithType:LKUserCenterModelTypeFavor];
        
        LKPost * post = datasource[index];
        LKPost * post1 = index + 1 < datasource.count ? datasource[index + 1] : nil;
        LKPost * post2 = index + 2 < datasource.count ? datasource[index + 2] : nil;
        
        NSMutableArray * array = [NSMutableArray array];
        
        if (post) {
            [array addObject:post];
        }
        
        if (post1) {
            [array addObject:post1];
        }
        
        if (post2) {
            [array addObject:post2];
        }
        
        cell.posts = array;
        
        return cell;
        
    }
    
    ERROR(@"Crash...");
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.currentType) {
            
        case LKUserCenterModelTypePhotos:
        case LKUserCenterModelTypeFavor:
            return [LKUserCenterPhotoCell height];
        case LKUserCenterModelTypeFocus:
        case LKUserCenterModelTypeFans:
            return 58;
        default:
            return 0;
            break;
    }
    
    return 30;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * data = [self.userCenterModel dataWithType:self.currentType];

    switch (self.currentType) {
        case LKUserCenterModelTypePhotos:
        case LKUserCenterModelTypeFavor:
            ;
            break;
        case LKUserCenterModelTypeFocus:
        case LKUserCenterModelTypeFans:
            
            [LKUserCenterViewController pushUserCenterWithUser:data[indexPath.row] navigationController:self.navigationController];
            break;
        default:
            break;
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.inputView resignFirstResponder];
    
    [self.header handleScrollDidScroll:scrollView];
}

#pragma mark - ***** LKPostDetailViewControllerCancelFavorDelegate *****
- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didcancelFavorWithPost:(LKPost *)post {
    
    NSMutableArray *favorArray = self.userCenterModel.favorArray;
    for (LKPost *favorPost in favorArray) {
        
        if (favorPost.id.integerValue == post.id.integerValue) {
            
//            [self.tableView beginUpdates];
            [self.userCenterModel.favorArray removeObject:favorPost];
//            [self.tableView endUpdates];
            
            [self.tableView reloadData];
            
            break;
        }
    }
}

@end
