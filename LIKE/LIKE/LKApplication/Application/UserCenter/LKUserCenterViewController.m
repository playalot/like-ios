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
#import "LKPostThumbnailTableViewCell.h"
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
#import "LKPostTableViewController.h"

@interface LKUserCenterViewController () <UITableViewDataSource, UITableViewDelegate, LKPostDetailViewControllerCancelFavorDelegate, LKPostTableViewControllerDelegate>

LC_PROPERTY(strong) LCUIPullLoader *pullLoader;
LC_PROPERTY(strong) LCUITableView *tableView;
LC_PROPERTY(strong) LKHomepageHeader *header;
LC_PROPERTY(strong) BLKDelegateSplitter *delegateSplitter;

LC_PROPERTY(strong) LCUIButton *friendshipButton;
LC_PROPERTY(strong) LKInputView *inputView;
LC_PROPERTY(strong) LCUIActivityIndicatorView *loadingActivity;

LC_PROPERTY(strong) LKUserCenterModel *userCenterModel;
LC_PROPERTY(assign) LKUserCenterModelType currentType;
LC_PROPERTY(assign) BOOL isLocalUser;
LC_PROPERTY(strong) LCUIImageView *cartoonImageView;

LC_PROPERTY(strong) NSMutableArray *datasource;

LC_PROPERTY(strong) LKPostTableViewController *browsingViewController;

@end

@implementation LKUserCenterViewController

- (void)dealloc {
    self.tableView.delegate = nil;
    [self unobserveAllNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.header updateWithUser:self.user];
    [self setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self setNavigationBarHidden:NO animated:NO];
    ((LCUINavigationController *)self.navigationController).animationHandler = nil;
}

+ (LKUserCenterViewController *)pushUserCenterWithUser:(LKUser *)user navigationController:(UINavigationController *)navigationController {
    LKUserCenterViewController * userCenter = [[LKUserCenterViewController alloc] initWithUser:user];
    userCenter.needBackButton = YES;
    userCenter.settingButtonHidden = NO;
    [navigationController pushViewController:userCenter animated:YES];
    return userCenter;
}

- (instancetype)initWithUser:(LKUser *)user {
    if (self = [super init]) {
        self.user = user;
        self.isLocalUser = self.user.id.integerValue == [[LKLocalUser.singleton getCurrentUID] integerValue];
        LKUser * cache = LKUserInfoCache.singleton[self.user.id.description];
        if (!self.isLocalUser && cache) {
            self.user = cache;
        }
        
        if (self.isLocalUser) {
            [self observeNotification:LKUserCenterViewControllerReloadingData];
        }
        
        self.userCenterModel = [[LKUserCenterModel alloc] init];
        self.userInfoModel = [[LKUserInfoModel alloc] init];
    }
    return self;
}

- (void)updateTableHeaderView {
    LKSegmentHeader * tableViewHeader = (LKSegmentHeader *)self.tableView.tableHeaderView;
    [tableViewHeader setTitle:LC_NSSTRING_FORMAT(@"%@",self.userInfoModel.user.postCount) subTitle:LC_LO(@"照片") atIndex:0];
    [tableViewHeader setTitle:LC_NSSTRING_FORMAT(@"%@",self.userInfoModel.user.followCount) subTitle:LC_LO(@"关注") atIndex:1];
    [tableViewHeader setTitle:LC_NSSTRING_FORMAT(@"%@",self.userInfoModel.user.fansCount) subTitle:LC_LO(@"粉丝") atIndex:2];
    if (self.isLocalUser) {
        [tableViewHeader setTitle:LC_NSSTRING_FORMAT(@"%@",self.userInfoModel.user.favorCount) subTitle:LC_LO(@"收藏") atIndex:3];
    }
}

- (void)buildUI {
    if (!self.isLocalUser) {
        [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    }
    
    LCUIButton *titleBtn = [[LCUIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleBtn setImage:[UIImage imageNamed:@"HomeLikeIcon" useCache:YES] forState:UIControlStateNormal];
    self.titleView = (UIView *)titleBtn;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    self.tableView = [[LCUITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.viewFrameY = 20;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundViewColor = LKColor.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alpha = 0;
    self.view.ADD(self.tableView);
    
    self.cartoonImageView = LCUIImageView.view;
    self.cartoonImageView.viewFrameWidth = 169;
    self.cartoonImageView.viewFrameHeight = 245;
    self.cartoonImageView.viewCenterX = self.tableView.viewCenterX;
    self.cartoonImageView.viewFrameY = 52 + 48;
    self.tableView.ADD(self.cartoonImageView);
    self.cartoonImageView.hidden = YES;
    
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
    
    @weakly(self);
    self.header.headAction = ^(UIImageView * imageView){
        
        @normally(self);
        JTSImageInfo * info = [[JTSImageInfo alloc] init];
        NSString *imageURLString = LC_NSSTRING_IS_INVALID(self.user.originAvatar) ? self.user.originAvatar : self.user.avatar;
        info.imageURL = [NSURL URLWithString:imageURLString];
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
    
    self.header.labelAction = ^(id value){};
    
    if (self.needBackButton) {
        LCUIButton * backButton = LCUIButton.view;
        backButton.viewFrameWidth = 50;
        backButton.viewFrameHeight = 54 / 3 + 40;
        backButton.viewFrameY = 10;
        backButton.buttonImage = [UIImage imageNamed:@"NavigationBarBack.png" useCache:YES];
        backButton.showsTouchWhenHighlighted = YES;
        [backButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
        backButton.tag = 1002;
        [self.header addSubview:backButton];
    }
    
    if (self.isLocalUser) {
        
        if (!self.settingButtonHidden) {
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
        
    } else {
        
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
    
    // Header.
    LKSegmentHeader * tableViewHeader = LKSegmentHeader.view;
    tableViewHeader.viewFrameWidth = LC_DEVICE_WIDTH;
    tableViewHeader.viewFrameHeight = 55;
    
    [tableViewHeader addTitle:[NSString stringWithFormat:@"%@", @(self.user.postCount.integerValue)] subTitle:LC_LO(@"照片")];
    [tableViewHeader addTitle:[NSString stringWithFormat:@"%@", @(self.user.followCount.integerValue)] subTitle:LC_LO(@"关注")];
    [tableViewHeader addTitle:[NSString stringWithFormat:@"%@", @(self.user.fansCount.integerValue)] subTitle:LC_LO(@"粉丝")];
    
    if (self.isLocalUser) {
        [tableViewHeader addTitle:[NSString stringWithFormat:@"%@", @(self.user.favorCount.integerValue)] subTitle:LC_LO(@"收藏")];
    }
    
    tableViewHeader.didSelected = ^(NSInteger index){
        @normally(self);
        self.currentType = index;
        self.cartoonImageView.image= nil;
        self.pullLoader.canLoadMore = [self.userCenterModel canLoadMoreWithType:self.currentType];
        [self loadData:self.currentType diretion:LCUIPullLoaderDiretionTop];
    };
    
    self.tableView.tableHeaderView = tableViewHeader;
    
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
    self.pullLoader.canLoadMore = [self.userCenterModel canLoadMoreWithType:self.currentType];
    [self loadData:self.currentType diretion:LCUIPullLoaderDiretionTop];
    
//    [self.userCenterModel getDataAtFirstPage:YES type:LKUserCenterModelTypeFocus uid:self.user.id];
//    [self.userCenterModel getDataAtFirstPage:YES type:LKUserCenterModelTypeFans uid:self.user.id];
//    [self.userCenterModel getDataAtFirstPage:YES type:LKUserCenterModelTypeFavor uid:self.user.id];
    
    self.userInfoModel.requestFinished = ^(LKHttpRequestResult * result, NSString * error){
        @normally(self);
        if (!error){
            self.user = self.userInfoModel.user;
            [self.header updateWithUser:self.userInfoModel.user];
            [self updateTableHeaderView];
            [self updateFriendButton];
        }
    };
    
    // update user meta information
    [self updateUserMetaInfo];
    
    ((LCUINavigationController *)self.navigationController).animationHandler = ^id(UINavigationControllerOperation operation, UIViewController * fromVC, UIViewController * toVC){
        if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[LKPostDetailViewController class]]) {
            return [[LKPushAnimation alloc] init];
        }
        return nil;
    };
    
    if (self.tableView.viewFrameY != 0) {
        self.tableView.pop_springBounciness = 10;
        self.tableView.pop_springSpeed = 10;
        self.tableView.pop_spring.center = LC_POINT(self.tableView.viewCenterX, self.tableView.viewCenterY - 20);
        self.tableView.pop_spring.alpha = 1;
    }
}

- (void)updateUserMetaInfo {
    [self.userInfoModel getUserInfo:self.user.id];
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self dismissAction];
    }
}

#pragma mark -

-(void) handleNotification:(NSNotification *)notification {
    if ([notification is:LKUserCenterViewControllerReloadingData]) {
        [self loadData:self.currentType diretion:LCUIPullLoaderDiretionTop];
    }
}

#pragma mark -

- (void)loadMore {
    [self loadData:self.currentType diretion:LCUIPullLoaderDiretionBottom];
}

- (void)dismissAction {
    [self dismissOrPopViewController];
}

- (void)setAction {
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

- (void)friendShipAction {
    
    if([LKLoginViewController needLoginOnViewController:nil]){
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

-(void) updateFriendButton {
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

-(void) updateUserCache {
    [self.userInfoModel.rawUserInfo setObject:self.userInfoModel.user.isFollowing forKey:@"is_following"];
    LKUserInfoCache.singleton[self.user.id.description] = self.userInfoModel.rawUserInfo;
}

#pragma mark -

- (void)scrollToPostByIndex:(NSInteger)index {
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:(index / 3) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)loadData:(LKUserCenterModelType)type diretion:(LCUIPullLoaderDiretion)diretion {
    @weakly(self);
    self.userCenterModel.requestFinished = ^(LKUserCenterModelType type, NSString * error){
        @normally(self);
        [self.pullLoader endRefresh];
        
        // Update header user information
        [self.userInfoModel getUserInfo:self.user.id];
        
        NSArray * datasource = [self.userCenterModel dataWithType:type];
        if (!datasource || datasource.count == 0) {
            if (type == LKUserCenterModelTypePhotos) {
                self.cartoonImageView.hidden = self.userCenterModel.photoArray.count ? YES : NO;
                self.cartoonImageView.image = [UIImage imageNamed:@"segment_photo.png" useCache:YES];
            } else if (type == LKUserCenterModelTypeFocus) {
                self.cartoonImageView.hidden = self.userCenterModel.focusArray.count ? YES : NO;
                self.cartoonImageView.image = [UIImage imageNamed:@"segment_follow.png" useCache:YES];
            } else if (type == LKUserCenterModelTypeFans) {
                self.cartoonImageView.hidden = self.userCenterModel.fansArray.count ? YES : NO;
                self.cartoonImageView.image = [UIImage imageNamed:@"segment_fans.png" useCache:YES];
            } else if (type == LKUserCenterModelTypeFavor) {
                self.cartoonImageView.hidden = self.userCenterModel.favorArray.count ? YES : NO;
                self.cartoonImageView.image = [UIImage imageNamed:@"segment_favor.png" useCache:YES];
            }
        }
        
        if (error) {
            [self showTopMessageErrorHud:error];
        } else {
            
            // Reload data
            self.pullLoader.canLoadMore = [self.userCenterModel canLoadMoreWithType:type];
            self.datasource = [NSMutableArray arrayWithArray:[self.userCenterModel dataWithType:self.currentType]];
            [self.tableView reloadData];
        }
    };
    
    [self.userCenterModel cancelAllRequests];
    [self.userCenterModel getDataAtFirstPage:diretion == LCUIPullLoaderDiretionTop type:type uid:self.user.id];
    self.cartoonImageView.hidden = YES;
}

#pragma mark -

LC_HANDLE_UI_SIGNAL(PushPostDetail, signal) {
    
    if (self.currentType == LKUserCenterModelTypeFocus || self.currentType == LKUserCenterModelTypeFans) {
        return;
    }
    
    self.datasource = [NSMutableArray arrayWithArray:[self.userCenterModel dataWithType:self.currentType]];
    self.browsingViewController = [[LKPostTableViewController alloc] init];
    self.browsingViewController.delegate = self;
    self.browsingViewController.datasource = self.datasource;
    if (self.currentType == LKUserCenterModelTypePhotos) {
        self.browsingViewController.title = self.user.name ? self.user.name : LC_LO(@"我的照片");
        self.browsingViewController.cellHeadLineHidden = YES;
    } else {
        self.browsingViewController.title = LC_LO(@"我的收藏");
        self.browsingViewController.cellHeadLineHidden = NO;
    }
    self.browsingViewController.currentIndex = [self.datasource indexOfObject:signal.object];
    [self.browsingViewController watchForChangeOfDatasource:self dataSourceKey:@"datasource"];
    [self.browsingViewController refresh];
    [self.navigationController pushViewController:self.browsingViewController animated:YES];
}

#pragma mark - LKPostTableViewControllerDelegate
- (void)willLoadData:(LCUIPullLoaderDiretion)direction {
    [self loadData:self.currentType diretion:direction];
}

- (void)willNavigationBack:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:(index / 3) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentType == LKUserCenterModelTypePhotos || self.currentType == LKUserCenterModelTypeFavor) {
        NSArray * datasource = [self.userCenterModel dataWithType:self.currentType];
        NSInteger remainder = datasource.count % 3;
        return remainder ? datasource.count / 3 + 1 : datasource.count / 3;
    } else {
        return [self.userCenterModel dataWithType:self.currentType].count;
    }
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentType == LKUserCenterModelTypePhotos) {
        
        LKPostThumbnailTableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Photos" andClass:[LKPostThumbnailTableViewCell class]];
        
        NSInteger index = indexPath.row * 3;
        
        NSArray *datasource = self.datasource;
        
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
        
        LKPostThumbnailTableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Favor" andClass:[LKPostThumbnailTableViewCell class]];
        NSInteger index = indexPath.row * 3;
        NSArray * datasource = self.datasource;
        
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
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentType == LKUserCenterModelTypePhotos || self.currentType == LKUserCenterModelTypeFavor) {
        return [LKPostThumbnailTableViewCell height];
    }
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.inputView resignFirstResponder];
    [self.header handleScrollDidScroll:scrollView];
}

LC_HANDLE_NAVIGATION_SIGNAL(UnfavouritePost, signal) {
//    LKPost *signalPost = (LKPost *)signal.object;
//    NSInteger updatedIndex = -1;
//    for (LKPost *post in self.datasource) {
//        if (post.id.integerValue == signalPost.id.integerValue) {
//            updatedIndex = [self.datasource indexOfObject:post];
//            break;
//        }
//    }
//    
//    if (updatedIndex < 0) {
//        return;
//    }
//    
//    [self.datasource removeObject:signalPost];
    [self.tableView reloadData];
}

#pragma mark - ***** LKPostDetailViewControllerCancelFavorDelegate *****
- (void)postDetailViewController:(LKPostDetailViewController *)ctrl didcancelFavorWithPost:(LKPost *)post {
    NSMutableArray *favorArray = self.userCenterModel.favorArray;
    for (LKPost *favorPost in favorArray) {
        if (favorPost.id.integerValue == post.id.integerValue) {
            [self.tableView beginUpdates];
            [self.userCenterModel.favorArray removeObject:favorPost];
            [self.tableView endUpdates];
            [self.tableView reloadData];
            break;
        }
    }
}

@end
