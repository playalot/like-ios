//
//  LKPostDetailViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/4/20.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKPostDetailViewController.h"
#import "BLKDelegateSplitter.h"
#import "SquareCashStyleBehaviorDefiner.h"
#import "LKTagsView.h"
#import "LKPostTagsDetailModel.h"
#import "LKPostDetailCell.h"
#import "LKUserCenterViewController.h"
#import "LKInputView.h"
#import "LKTagAddModel.h"
#import "LKHomeViewController.h"
#import "LKUserCenterViewController.h"
#import "JTSImageViewController.h"
#import "LKLoginViewController.h"
#import "LKPhotoAlbum.h"
#import "LKPopAnimation.h"
#import "LKLikesPage.h"
#import "LKShareTools.h"
#import "LCUIImageCache.h"
#import "LKShareTagsView.h"
#import "LCUIImageLoadConnection.h"
#import "LKTagCommentsViewController.h"
#import "LKTime.h"
#import "LKPresentAnimation.h"
#import "ADTickerLabel.h"
#import "UIImageView+WebCache.h"
#import "RMPZoomTransitionAnimator.h"
#import "LKLoginViewIp4Controller.h"
#import "UIImage+GIF.h"

@interface LKPostDetailViewController () <UITableViewDataSource,UITableViewDelegate,JTSImageViewControllerDismissalDelegate,UINavigationControllerDelegate,UIViewControllerTransitioningDelegate, LKTagCommentsViewControllerDelegate>

LC_PROPERTY(strong) BLKDelegateSplitter *delegateSplitter;
LC_PROPERTY(strong) LKInputView *inputView;

LC_PROPERTY(strong) LCUIPullLoader *pullLoader;

LC_PROPERTY(strong) LCUIImageView *userHead;
LC_PROPERTY(strong) LCUILabel *userName;
LC_PROPERTY(strong) ADTickerLabel *userLikes;
LC_PROPERTY(strong) LCUILabel *likesTip;
LC_PROPERTY(strong) LCUILabel *postTime;
LC_PROPERTY(strong) LCUIButton *location;
LC_PROPERTY(strong) LCUILabel *timeLabel;

LC_PROPERTY_MODEL(LKPostTagsDetailModel, tagsListModel);

LC_PROPERTY(copy) NSString *bigContentURL;
LC_PROPERTY(strong) AFHTTPRequestOperation *bigImageRequestOperation;

LC_PROPERTY(strong) LKPresentAnimation *animator;
LC_PROPERTY(strong) UIView *blackMask;

LC_PROPERTY(strong) LKShareTools *shareTools;

LC_PROPERTY(assign) BOOL favorited;

LC_PROPERTY(assign) BOOL isBackgroundImageGIF;

/**
 *  记录下当前的标签
 */
@property (nonatomic, strong) LKTag *tag;
/**
 *  用户like数量
 */
@property (nonatomic, assign) NSInteger userLikesCount;

@end

@implementation LKPostDetailViewController

-(void) dealloc
{
    [self.bigImageRequestOperation cancel];
    self.bigImageRequestOperation = nil;
    
    self.tableView.delegate = nil;
    [self cancelAllRequests];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES animated:NO];
    [[LKNavigator navigator].tabBarController setTabBarHidden:YES animated:NO];
    
    [self.header.headImageView removeFromSuperview];
    [self.header.nameLabel removeFromSuperview];
    [self.header.icon removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.tableView.viewFrameY != 0) {
        self.tableView.pop_springBounciness = 10;
        self.tableView.pop_springSpeed = 10;
        self.tableView.pop_spring.center = LC_POINT(self.tableView.viewCenterX, self.tableView.viewCenterY - 30);
        self.tableView.pop_spring.alpha = 1;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.inputView resignFirstResponder];
    [self.shareTools hideTools];
    
    [self setNavigationBarHidden:NO animated:animated];
    [[LKNavigator navigator].tabBarController setTabBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

#pragma mark -

-(instancetype) initWithPost:(LKPost *)post {
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.post = post;
        if (self.post.user.id.integerValue) {
            LKUser * user = LKUserInfoCache.singleton[self.post.user.id.description];
            if(!self.post.user.likes && user){
                self.post.user = user;
            }            
        }
    }
    
    return self;
}

- (void)getUserInfoWithPost:(LKPost *)post {
    
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@", post.id]].GET_METHOD();
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        if (result.state == LKHttpRequestStateFinished) {
            NSDictionary *resultData = result.json[@"data"];
            self.post = [LKPost objectFromDictionary:resultData];
        } else if (result.state == LKHttpRequestStateFailed) {
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

/**
 *  设置打开页面的动画样式
 */
-(void) setPresendModelAnimationOpen {
    self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    self.animator = [[LKPresentAnimation alloc] init];
    self.navigationController.transitioningDelegate = self.animator;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    [self getUserInfoWithPost:self.post];
    
    self.tagsListModel = LKPostTagsDetailModel.new;
    
    @weakly(self);
    
    self.tagsListModel.associatedTags = self.post.tags;
    self.tagsListModel.requestFinished = ^(LKHttpRequestResult * result , NSString * error){
        
        @normally(self);

        if (error) {
            [self showTopMessageErrorHud:error];
        } else {
            [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25];
        }
    };
    
    // Load...
    [self.tagsListModel loadDataWithPostID:self.post.id getMore:NO];
}

-(void) buildUI {
    self.view.backgroundColor = LKColor.backgroundColor;
    
    self.tableView = [[LCUITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.viewFrameY = 30;
    self.tableView.viewFrameHeight = self.view.viewFrameHeight - 44;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = LKColor.backgroundColor;
    self.tableView.backgroundViewColor = LKColor.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.alpha = 0;
    self.view.ADD(self.tableView);
    
    // Header
    {
        CGSize size = [LKUIKit parsingImageSizeWithURL:self.post.preview];
        
        // Header
        if (size.width > LC_DEVICE_WIDTH) {
            
            size.height = LC_DEVICE_WIDTH / size.width * size.height;
            size.width = LC_DEVICE_WIDTH;
        }

        // 图片详情页header
        self.header = [[LKHomepageHeader alloc] initWithFrame:CGRectMake(0.0, 0, CGRectGetWidth(self.view.frame), size.height) maxHeight:size.height minHeight:64];
        self.header.clipsToBounds = YES;
        self.header.backgroundView.autoMask = NO;
        self.header.scrollView = self.tableView;
//        self.header.maskView.backgroundColor = [UIColor clearColor];
        [self.header.maskView removeFromSuperview];
        self.header.maskView = nil;
        self.header.backgroundView.showIndicator = YES;
//        self.header.backgroundView.url = self.post.content
        [self.header.backgroundView sd_setImageWithURL:[NSURL URLWithString:self.post.preview] placeholderImage:nil];
        
        if ([self.post.preview rangeOfString:@".gif"].location != NSNotFound) {
            self.isBackgroundImageGIF = YES;
        }
        
        self.header.backgroundView.frame = CGRectMake(0, 0, size.width, size.height);
        
        SquareCashStyleBehaviorDefiner * behaviorDefiner = [[SquareCashStyleBehaviorDefiner alloc] init];
        [behaviorDefiner addSnappingPositionProgress:0.0 forProgressRangeStart:0.0 end:0.5];
        [behaviorDefiner addSnappingPositionProgress:1.0 forProgressRangeStart:0.5 end:1.0];
        behaviorDefiner.snappingEnabled = NO;
        behaviorDefiner.elasticMaximumHeightAtTop = NO;
        self.header.behaviorDefiner = behaviorDefiner;
        
        self.delegateSplitter = [[BLKDelegateSplitter alloc] initWithFirstDelegate:behaviorDefiner secondDelegate:self];
        self.tableView.delegate = (id<UITableViewDelegate>)self.delegateSplitter;
        
        [self.view addSubview:self.header];
        
        self.tableView.contentInset = UIEdgeInsetsMake(self.header.maximumBarHeight - 20, 0.0, 0.0, 0.0);
        
        @weakly(self);
        
        self.header.backgroundAction = ^(id value){
            
            @normally(self);

            [self.shareTools hideTools];
            
            if (self.inputView.isFirstResponder) {
                
                [self.inputView resignFirstResponder];
            }
            else{
                
                UIView * nav = self.header.FIND(1001);
                UIView * back = self.header.FIND(1002);
                UIView * more = self.header.FIND(1003);
                
            
                LC_FAST_ANIMATIONS_F(0.1, ^{
                    nav.alpha = 0;
                    back.alpha = 0;
                    more.alpha = 0;
                }, ^(BOOL finished){
                
                    
                });
                
                JTSImageInfo * info = [[JTSImageInfo alloc] init];
                NSString * content = nil;
                
                if (self.post.raw_image) {
                    NSArray * contents = [self.post.raw_image componentsSeparatedByString:@"?"];
                    if (contents.count) {
                        content = [contents[0] stringByAppendingString:@"?imageView2/4/q/85"];
                    }
                }
                
                info.imageURL = [NSURL URLWithString:content];
                info.referenceRect = self.header.frame;
                info.referenceView = self.header.superview;
                info.fromView = self.header.backgroundView;
                
                // Setup view controller
                JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                       initWithImageInfo:info
                                                       mode:JTSImageViewControllerMode_Image
                                                       backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
                
                imageViewer.dismissalDelegate = self;
                // Present the view controller.
                [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
                
            }
        };
        
        LCUIView *navView = LCUIView.view;
        navView.backgroundColor = LKColor.color;
        navView.viewFrameWidth = LC_DEVICE_WIDTH;
        navView.viewFrameHeight = 44;
        
        LCUILabel *timeLabel = LCUILabel.view;
        timeLabel.font = LK_FONT(18);
        timeLabel.textAlignment = UITextAlignmentCenter;
        timeLabel.viewFrameWidth = 200;
        timeLabel.viewFrameHeight = timeLabel.font.lineHeight;
        timeLabel.viewCenterX = navView.viewCenterX;
        timeLabel.viewCenterY = navView.viewCenterY;
        navView.ADD(timeLabel);
        self.timeLabel = timeLabel;
        
        // 导航栏返回上一级按钮
        LCUIButton * backButton = LCUIButton.view;
        backButton.viewFrameWidth = 80;
        backButton.viewFrameHeight = 80;
        backButton.viewFrameY = -17 + 20;
        backButton.viewFrameX = -15;
        backButton.buttonImage = [UIImage imageNamed:@"NavigationBarBackShadow.png" useCache:YES];
        backButton.showsTouchWhenHighlighted = YES;
        [backButton addTarget:self action:@selector(_dismissAction) forControlEvents:UIControlEventTouchUpInside];
        backButton.tag = 1002;
        [self.header addSubview:backButton];
        
        // 导航栏更多按钮
        LCUIButton * moreButton = LCUIButton.view;
        moreButton.viewFrameWidth = 80;
        moreButton.viewFrameHeight = 80;
        moreButton.viewFrameX = LC_DEVICE_WIDTH - moreButton.viewFrameWidth + 15;
        moreButton.viewFrameY = - 17 + 20;
        moreButton.buttonImage = [UIImage imageNamed:@"NavigationBarMoreShadow.png" useCache:YES];
        moreButton.showsTouchWhenHighlighted = YES;
        [moreButton addTarget:self action:@selector(_moreAction) forControlEvents:UIControlEventTouchUpInside];
        moreButton.tag = 1003;
        [self.header addSubview:moreButton];
    }
    
    // 输入框
    self.inputView = LKInputView.view;
    self.inputView.viewFrameY = self.view.viewFrameHeight - self.inputView.viewFrameHeight;
    self.view.ADD(self.inputView);
    
    @weakly(self);
    
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
        
        if ([self _checkTag:string onTags:self.post.tags]) {
            [self _addTag:string onPost:self.post];
        } else {
            [self showTopMessageErrorHud:LC_LO(@"该标签已存在")];
        }
    };
}

#pragma mark - ***** 放大后的headerView dismiss的时候调用 *****

- (void) imageViewerDidDismiss:(JTSImageViewController *)imageViewer
{
    UIView * nav = self.header.FIND(1001);
    UIView * back = self.header.FIND(1002);
    UIView * more = self.header.FIND(1003);

    LC_FAST_ANIMATIONS(0.15, ^{
        
        nav.alpha = 1;
        back.alpha = 1;
        more.alpha = 1;
    });
}

#pragma mark - ***** 评论View *****

-(void) openCommentsView:(LKTag *)tag
{
    [self _beginComment:tag];
}

#pragma mark -
/**
 *  检查标签的tag
 */
-(BOOL) _checkTag:(NSString *)tag onTags:(NSArray *)onTags
{
    NSArray * tmp = onTags;
    
    if (onTags.count == 0) {
        
        tmp = self.tagsListModel.tags;
    }
    
    for (LKTag * oTag in tmp) {
        
        if ([oTag.tag isEqualToString:tag]) {
            
            self.inputView.textField.text = nil;
            return NO;
        }
    }
    
    return YES;
}

/**
 *  添加tag
 */
-(void) _addTag:(NSString *)tag onPost:(LKPost *)post
{
    if (UI_IS_IPHONE4) {
        if ([LKLoginViewIp4Controller needLoginOnViewController:self.navigationController]) {
            return;
        }
    } else {
        if ([LKLoginViewController needLoginOnViewController:self.navigationController]) {
            return;
        }
    }
    
    [self.inputView resignFirstResponder];
    
    [self cancelAllRequests];
    
    @weakly(self);
    
    [LKTagAddModel addTagString:tag onPost:post requestFinished:^(LKHttpRequestResult *result, NSString *error) {
        
        @normally(self);
        
        if (error) {
            
            [self showTopMessageErrorHud:error];
        }
        else{
            
            // insert...
            LKTag *tag = [LKTag objectFromDictionary:result.json[@"data"]];
            
            if (!tag) {
                // input view...
                [self.inputView resignFirstResponder];
                self.inputView.textField.text = @"";
                return;
            }
            
            tag.user = LKLocalUser.singleton.user;
            
            [self.tagsListModel.tags insertObject:tag atIndex:0];
            
            post.user.likes = @(post.user.likes.integerValue + 1);
            
            [self.tableView reloadData];
            
            // input view...
            [self.inputView resignFirstResponder];
            
            self.inputView.textField.text = @"";
            
            self.post.tags = self.tagsListModel.tags;
            if (self.delegate && [self.delegate respondsToSelector:@selector(postDetailViewController:didUpdatedPost:)]) {
                [self.delegate postDetailViewController:self didUpdatedPost:self.post];
            }
        }
        
    }];
}


-(void) _dismissAction
{
    [self dismissOrPopViewController];
}

-(void) _moreAction {
    [self.inputView resignFirstResponder];
    
    NSString *favorStr = self.post.favorited ? @"取消收藏" : @"收 藏";
    
    @weakly(self);

    if (self.post.user.id.integerValue == LKLocalUser.singleton.user.id.integerValue) {
        
        NSMutableArray *titles = [NSMutableArray array];
        [titles addObject:LC_LO(@"删除")];
        if (self.post.user.id.integerValue != [[LKLocalUser.singleton getCurrentUID] integerValue]) {
            [titles addObject:LC_LO(favorStr)];
        }
        [titles addObject:LC_LO(@"保存图片")];
        
        [LKActionSheet showWithTitle:nil/*LC_LO(@"更多")*/ buttonTitles:titles didSelected:^(NSInteger index) {
            
            @normally(self);

            if (index == 0){
                
                // 删除
                [self _delete];
                
            } else if (index == 1){
                
                if (self.header.backgroundView.image) {
                    
                    [LKPhotoAlbum saveImage:self.header.backgroundView.image showTip:YES];
                }
            }
        }];
    } else {
        
        UIImage *shareImage = [self buildShareImage:0];
        [LKActionSheet showWithTitle:LC_LO(@"分享这张照片") buttonTitles:@[LC_LO(favorStr),LC_LO(@"举 报")] shareTitles:@[LC_LO(@"微信好友"), LC_LO(@"朋友圈"), LC_LO(@"QQ好友"), LC_LO(@"微博")] shareImage:shareImage didSelected:^(NSInteger index) {
           
            @normally(self);
            
            if (index == 0) {
                
                [self favoriteImageWithStatus:self.post.favorited];
                
            } else if (index == 1) {
                
                [self reportReason];
            }
        }];
    }
}

/**
 *  举报原因
 */
- (void)reportReason {
    
    @weakly(self);
    
    [LKActionSheet showWithTitle:nil buttonTitles:@[LC_LO(@"自拍"),LC_LO(@"广告"),LC_LO(@"色情"),LC_LO(@"谣言"),LC_LO(@"恶意营销"),LC_LO(@"侮辱诋毁"),LC_LO(@"侵权举报(诽谤、抄袭、冒用...)")] didSelected:^(NSInteger index) {
        
        @normally(self);

        if (index != 7) {
            
            [self reportWithIndex:index];
        }
    }];
}

/**
 *  举报
 */
- (void)reportWithIndex:(NSInteger)index {
    
    if (UI_IS_IPHONE4) {
        if ([LKLoginViewIp4Controller needLoginOnViewController:self.navigationController]) {
            return;
        }
    } else {
        if ([LKLoginViewController needLoginOnViewController:self.navigationController]) {
            return;
        }
    }
    
    [self cancelAllRequests];
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@/report", self.post.id]].AUTO_SESSION().POST_METHOD();
    
    switch (index) {
        case 0:
            [interface addParameter:LC_LO(@"自拍") key:@"reason"];
            break;
            
        case 1:
            [interface addParameter:LC_LO(@"广告") key:@"reason"];
            break;
            
        case 2:
            [interface addParameter:LC_LO(@"色情") key:@"reason"];
            break;
            
        case 3:
            [interface addParameter:LC_LO(@"谣言") key:@"reason"];
            break;
            
        case 4:
            [interface addParameter:LC_LO(@"恶意营销") key:@"reason"];
            break;
            
        case 5:
            [interface addParameter:LC_LO(@"侮辱诋毁") key:@"reason"];
            break;
            
        case 6:
            [interface addParameter:LC_LO(@"侵权举报(诽谤、抄袭、冒用...)") key:@"reason"];
            break;
            
        default:
            break;
    }
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            [LCUIAlertView showWithTitle:nil message:LC_LO(@"感谢您的举报！") cancelTitle:LC_LO(@"好的") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
                
            }];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
        
    }];
}

/**
 *  收藏图片
 */
- (void)favoriteImageWithStatus:(BOOL)favorited {
    
    if (favorited) {
        
        if ([self.cancelFavordelegate respondsToSelector:@selector(postDetailViewController:didcancelFavorWithPost:)]) {
            
            [self.cancelFavordelegate postDetailViewController:self didcancelFavorWithPost:self.post];
        }
    }
    
    LKHttpRequestInterface *interface;
    
    if (!favorited) {
        
        // 收藏图片
        interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@/favorite",self.post.id]].POST_METHOD();
    } else {
        
        // 取消收藏
        interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@/favorite",self.post.id]].DELETE_METHOD();
    }
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
                        
            self.post.favorited = !favorited;
            
            if (self.post.favorited) {
                [self showSuccessHud:LC_LO(@"收藏成功")];
                if (self.delegate && [self.delegate respondsToSelector:@selector(postDetailViewController:didFavouritePost:)]) {
                    [self.delegate postDetailViewController:self didFavouritePost:self.post];
                }
                
            } else {
                [self showSuccessHud:LC_LO(@"已取消收藏")];
                if (self.delegate && [self.delegate respondsToSelector:@selector(postDetailViewController:didUnfavouritePost:)]) {
                    [self.delegate postDetailViewController:self didUnfavouritePost:self.post];
                }
            }
            
        } else if (result.state == LKHttpRequestStateFailed) {
            
            
        }
    }];
}

#pragma mark - ***** 加载大图 *****

-(void) loadBigImage
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@",self.post.id]].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            if ([self.post.raw_image isEqualToString:result.json[@"data"][@"raw_image"]]) {
                return;
            }
            
            self.post.place = [result.json[@"data"][@"place"] isKindOfClass:[NSString class]] ? result.json[@"data"][@"place"] : nil;
            self.post.timestamp = result.json[@"data"][@"created"];
            self.bigContentURL = result.json[@"data"][@"raw_image"];
            
            UIImage * image = [LCUIImageCache.singleton imageWithKey:self.bigContentURL];
            
            if (!image) {
                
                self.bigImageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.bigContentURL]]];
                self.bigImageRequestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                
                [self.bigImageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation, id responseObject) {
                    
                    @normally(self);
                    
                    NSString * fullPath = [LCUIImageCache.singleton.fileCache fileNameForKey:[self.bigContentURL MD5]];
                    
                    [self.bigImageRequestOperation.responseData writeToFile:fullPath atomically:YES];
                    
                    CATransition * animation = [CATransition animation];
                    [animation setDuration:0.25];
                    [animation setType:kCATransitionFade];
                    [animation setSubtype:kCATransitionFromRight];
                    [self.header.backgroundView.layer addAnimation:animation forKey:@"transition"];
                    
                    self.header.backgroundView.image = responseObject;
                    
                } failure:nil];

                [self.bigImageRequestOperation start];
            }
            else{
                
                CATransition * animation = [CATransition animation];
                [animation setDuration:0.25];
                [animation setType:kCATransitionFade];
                [animation setSubtype:kCATransitionFromRight];
                [self.header.backgroundView.layer addAnimation:animation forKey:@"transition"];
                
                self.header.backgroundView.image = [LCUIImageCache.singleton imageWithKey:self.bigContentURL];
            }
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

        }
        else if (result.state == LKHttpRequestStateFailed){
            
        }
        
    }];
}

/**
 *  举报
 */
-(void) _report
{
    if (UI_IS_IPHONE4) {
        if ([LKLoginViewIp4Controller needLoginOnViewController:self.navigationController]) {
            return;
        }
    } else {
        if ([LKLoginViewController needLoginOnViewController:self.navigationController]) {
            return;
        }
    }
    
    
    [self cancelAllRequests];
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@/report", self.post.id]].AUTO_SESSION().POST_METHOD();
    

    @weakly(self);

    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            [LCUIAlertView showWithTitle:nil message:LC_LO(@"感谢您的举报！") cancelTitle:LC_LO(@"好的") otherTitle:nil didTouchedBlock:^(NSInteger integerValue) {
                
            }];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }

    }];
}

/**
 *  删除
 */
-(void) _delete
{
    @weakly(self);

    [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"确定要删除这个照片吗？") cancelTitle:LC_LO(@"取消") otherTitle:LC_LO(@"删除") didTouchedBlock:^(NSInteger integerValue) {
       
        @normally(self);

        if (integerValue == 1) {
            
            [self cancelAllRequests];
            
            LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@", self.post.id]].AUTO_SESSION().DELETE_METHOD();;
            
            [self request:interface complete:^(LKHttpRequestResult *result) {
                
                if (result.state == LKHttpRequestStateFinished) {
                    
                    [self dismissOrPopViewController];
                    
                    [self postNotification:LKHomeViewControllerReloadingData];
                    [self postNotification:LKUserCenterViewControllerReloadingData];
                }
                else if (result.state == LKHttpRequestStateFailed){
                    
                    [self showTopMessageErrorHud:result.error];
                }
            }];
        }
    }];
}

/**
 *  开启评论页
 */
-(void) _beginComment:(LKTag *)tag {
    // check
    if (UI_IS_IPHONE4) {
        if(![LKLoginViewIp4Controller needLoginOnViewController:self]){
            [self.inputView resignFirstResponder];
            LKTagCommentsViewController *comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
            // 传递发布者模型数据
            comments.publisher = self.post;
            // 设置代理
            comments.delegate = self;
            self.tag = tag;
            [self.navigationController pushViewController:comments animated:YES];
            //        [comments performSelector:@selector(inputBecomeFirstResponder) withObject:nil afterDelay:0.25];
        }
    } else {
        if(![LKLoginViewController needLoginOnViewController:self]){
            [self.inputView resignFirstResponder];
            LKTagCommentsViewController *comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
            // 传递发布者模型数据
            comments.publisher = self.post;
            // 设置代理
            comments.delegate = self;
            self.tag = tag;
            [self.navigationController pushViewController:comments animated:YES];
            //        [comments performSelector:@selector(inputBecomeFirstResponder) withObject:nil afterDelay:0.25];
        }
    }
}

#pragma mark - ***** LKTagCommentsViewControllerDelegate *****
- (void)tagCommentsViewController:(LKTagCommentsViewController *)ctrl didClickedDeleteBtn:(LCUIButton *)deleteBtn {
    for (LKTag *tag in self.tagsListModel.tags) {
        
        if ([self.tag.tag isEqualToString:tag.tag]) {
            [self.tagsListModel.tags removeObject:tag];
            // 调用代理
            self.post.tags = self.tagsListModel.tags;
            if (self.delegate && [self.delegate respondsToSelector:@selector(postDetailViewController:didUpdatedPost:)]) {
                [self.delegate postDetailViewController:self didUpdatedPost:self.post];
            }
            // 刷新数据
            [self.tableView reloadData];
            break;
        }
    }
    
    // 调用代理
    self.post.tags = self.tagsListModel.tags;
    if (self.delegate && [self.delegate respondsToSelector:@selector(postDetailViewController:didUpdatedPost:)]) {
        [self.delegate postDetailViewController:self didUpdatedPost:self.post];
    }
    
    // 刷新数据
    [self.tableView reloadData];
}

#pragma mark -

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal)
{
    [LKUserCenterViewController pushUserCenterWithUser:signal.object navigationController:self.navigationController];
}

#pragma mark -

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
     
        return 1;
    }
    else if (section == 1)
    {
        return self.tagsListModel.tags.count;
    }

    return 0;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
     
        // 用户信息cell
        LCUITableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"User" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            
//            configurationCell.backgroundColor = [UIColor clearColor];
            configurationCell.contentView.backgroundColor = [UIColor whiteColor];
            configurationCell.selectionStyle = UITableViewCellSelectionStyleNone;

            // 用户头像
            self.userHead = LCUIImageView.view;
            self.userHead.viewFrameX = 16;
            self.userHead.viewFrameY = 7;
            self.userHead.viewFrameWidth = 40;
            self.userHead.viewFrameHeight = 40;
            self.userHead.cornerRadius = 40. / 2.;
            self.userHead.backgroundColor = [UIColor lightGrayColor];
            configurationCell.ADD(self.userHead);
            
            // 用户昵称
            self.userName = LCUILabel.view;
            self.userName.font = LK_FONT_B(14);
            self.userName.textAlignment = UITextAlignmentLeft;
            self.userName.lineBreakMode = NSLineBreakByTruncatingTail;
            self.userName.viewFrameY = 9;
            self.userName.viewFrameX = self.userHead.viewRightX + 14;
            self.userName.viewFrameWidth = LC_DEVICE_WIDTH - self.userName.viewFrameX - 75;
            self.userName.viewFrameHeight = self.userName.font.lineHeight;
            self.userName.textColor = LC_RGB(51, 51, 51);
            configurationCell.ADD(self.userName);
            
            // 用户like数量
            self.userLikes = ADTickerLabel.view;
            self.userLikes.viewFrameWidth = LC_DEVICE_WIDTH / 2 - 10 - 5;
            self.userLikes.viewFrameHeight = LK_FONT(10).lineHeight;
            self.userLikes.viewFrameY = self.userName.viewFrameY + 4;
            self.userLikes.font = LK_FONT(10);
            self.userLikes.textAlignment = UITextAlignmentLeft;
            self.userLikes.textColor = LC_RGB(51, 51, 51);
            self.userLikes.changeTextAnimationDuration = 0.25;
            configurationCell.ADD(self.userLikes);
            
            // like标识,用于和数量拼接
            self.likesTip = LCUILabel.view;
            self.likesTip.font = LK_FONT(10);
            self.likesTip.textAlignment = UITextAlignmentLeft;
            self.likesTip.textColor = LC_RGB(51, 51, 51);
            self.likesTip.text = @"likes";
            self.likesTip.FIT();
            self.likesTip.viewFrameY = self.userLikes.viewFrameY;
            self.likesTip.viewFrameHeight = LK_FONT(10).lineHeight;
            configurationCell.ADD(self.likesTip);
            
            // 发布时间
            self.postTime = LCUILabel.view;
            self.postTime.viewFrameY = self.userName.viewBottomY + 5;
            self.postTime.viewFrameX = self.userHead.viewRightX + 14;
            self.postTime.viewFrameWidth = self.userName.viewFrameWidth;
            self.postTime.viewFrameHeight = 14;
            self.postTime.textAlignment = UITextAlignmentLeft;
            self.postTime.font = LK_FONT(12);
            self.postTime.lineBreakMode = NSLineBreakByTruncatingMiddle;
            self.postTime.textColor = LC_RGB(140, 133, 126);
            configurationCell.ADD(self.postTime);
            
            
            // 定位
//            self.location = LCUIButton.view;
//            self.location.titleFont = LK_FONT(10);
//            self.location.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
//            self.location.titleLabel.textAlignment = UITextAlignmentRight;
//            self.location.titleColor = LC_RGB(136, 136, 136);
//            self.location.viewFrameY = self.userName.viewBottomY + 2;
//            self.location.viewFrameHeight = self.location.titleFont.lineHeight;
//            self.location.hidden = YES;
//            configurationCell.ADD(self.location);
            
            
            // 分享工具
            if (!self.isBackgroundImageGIF) {
                self.shareTools = [[LKShareTools alloc] init];
                configurationCell.ADD(self.shareTools);
            }
            
        }];
        
        
        @weakly(self);
        
        self.shareTools.willShow = ^(id value){
            
            @normally(self);
            
            LC_FAST_ANIMATIONS(0.25, ^{
                
                self.userName.alpha = 0;
                self.userHead.alpha = 0;
                self.postTime.alpha = 0;
                self.likesTip.alpha = 0;
                self.userLikes.alpha = 0;
//                self.location.alpha = 0;
            });
        };
        
        self.shareTools.willHide = ^(id value){
            
            @normally(self);
            
            LC_FAST_ANIMATIONS(0.25, ^{
                
                self.userName.alpha = 1;
                self.userHead.alpha = 1;
                self.postTime.alpha = 1;
                self.likesTip.alpha = 1;
                self.userLikes.alpha = 1;
            });
        };
        
        self.shareTools.willShareImage = ^UIImage *(NSInteger index){
            @normally(self);
            return [self buildShareImage:index];
        };
        
        
        self.timeLabel.text = [NSString stringWithFormat:@"%@",
                             [LKTime dateNearByTimestamp:self.post.timestamp]];
        self.userHead.url = self.post.user.avatar;
        self.userName.text = self.post.user.name;
        [self.userLikes setText:self.post.user.likes.description animated:NO];

        
        CGSize likeSize = [self.userLikes.text sizeWithFont:LK_FONT(10) byWidth:200];

        self.userLikes.viewFrameWidth = likeSize.width;
        self.likesTip.FIT();
        
        CGFloat maxWidth = LC_DEVICE_WIDTH - self.userName.viewFrameX - 75 - self.likesTip.viewFrameWidth - self.userLikes.viewFrameWidth - 15;
        
        self.userName.viewFrameWidth = 1000;
        self.userName.FIT();    // sizeToFit
        self.userName.viewFrameWidth = self.userName.viewFrameWidth > maxWidth ? maxWidth : self.userName.viewFrameWidth;
        self.userLikes.viewFrameX = self.userName.viewRightX + 5;
        
        CGFloat width = [self.post.user.likes.description sizeWithFont:self.userLikes.font byWidth:1000].width;
        
        self.likesTip.viewFrameX = self.userLikes.viewFrameX + width + 5;
        
        self.postTime.text = [NSString stringWithFormat:@"%@ %@ %@", [LKTime dateNearByTimestamp:self.post.timestamp], self.post.place.length ? LC_LO(@"来自") : @"", self.post.place.length ? self.post.place : @""];
        
//        if (self.post.place != nil) {
//            self.location.hidden = NO;
//            self.location.viewFrameX = self.likesTip.viewRightX + 10;
//            [self.location setImage:[UIImage imageNamed:@"Location.png" useCache:YES] forState:UIControlStateNormal];
//            self.location.title = self.post.place;
//            CGSize locationSize = [self.location.title sizeWithFont:LK_FONT(10) byHeight:LK_FONT(10).lineHeight];
//            self.location.viewFrameWidth = locationSize.width + 10;
//        }
        
        return cell;
    }
    else if(indexPath.section == 1){
        
        LKPostDetailCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Tags" andClass:[LKPostDetailCell class]];
        
        cell.cellIndexPath = indexPath;
        cell.tagDetail = self.tagsListModel.tags[indexPath.row];
        
        @weakly(self);
        
        // 标签被移除
        cell.didRemoved = ^(NSIndexPath * _indexPath){
          
            @normally(self);
            
            [self.tagsListModel.tags removeObjectAtIndex:_indexPath.row];
            
            self.PERFORM_DELAY(@selector(reloadDataAndUpdate), nil, 0);
            
            self.post.tags = self.tagsListModel.tags;
            if (self.delegate && [self.delegate respondsToSelector:@selector(postDetailViewController:didUpdatedPost:)]) {
                [self.delegate postDetailViewController:self didUpdatedPost:self.post];
            }
        };
        
        // 标签被改变
        cell.didChanged = ^(LKTag * tag){
          
            @normally(self);
        
            if (tag.isLiked) {
                
                self.post.user.likes = @(self.post.user.likes.integerValue + 1);
                [tag.likers insertObject:LKLocalUser.singleton.user atIndex:0];
            }
            else{
                
                self.post.user.likes = @(self.post.user.likes.integerValue - 1);
            }
            
            self.userLikes.text = self.post.user.likes.description;
            
            [UIView animateWithDuration:0.25 animations:^{
               
                CGFloat width = [self.post.user.likes.description sizeWithFont:self.userLikes.font byWidth:1000].width;
                
                self.likesTip.viewFrameX = self.userLikes.viewFrameX + width + 5;
                self.location.viewFrameX = self.likesTip.viewRightX + 10;
            }];
            
            [self.shareTools hideTools];
            
            self.post.tags = self.tagsListModel.tags;
            if (self.delegate && [self.delegate respondsToSelector:@selector(postDetailViewController:didUpdatedPost:)]) {
                [self.delegate postDetailViewController:self didUpdatedPost:self.post];
            }
        };
        
        cell.willRequest = ^(LKTagItemView * item){
            @normally(self);
            if (item.tagValue.isLiked == NO) {
                [self newTagAnimation];
            }
        };
        
        // 显示点赞的人
        cell.showLikesAction = ^(LKTag * tag){
            
            @normally(self);
            
            //[self _beginComment:tag];

            UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            
            CGRect atViewFrame = [self.tableView convertRect:cell.frame toView:LC_KEYWINDOW];
            CGPoint point = LC_POINT(atViewFrame.size.width / 2, atViewFrame.origin.y + 53 / 2);
            
            LKLikesPage * page = [LKLikesPage pageWithTagID:tag.id
                                                       user:tag.user];
            
            @weakly(page);
            page.resetPointWhenOutOfSide = ^(id value){
                @normally(page);
                [UIView animateWithDuration:0.5 animations:^{
                    
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    
                } completion:^(BOOL finished) {
                    
                    CGRect atViewFrame = [self.tableView convertRect:cell.frame toView:LC_KEYWINDOW];
                    CGPoint point = LC_POINT(atViewFrame.size.width / 2, atViewFrame.origin.y + 53 / 2);
                    
                    [page showAtPoint:point inView:LC_KEYWINDOW];
                    
                }];
            };
            
            [page showAtPoint:point inView:LC_KEYWINDOW];
            
            page.didTapHead = ^(LKUser * user){
                
                [LKUserCenterViewController pushUserCenterWithUser:user navigationController:self.navigationController];
            };
            

            [self.shareTools hideTools];
        };
        
        
        // 开始评论
        cell.commentAction = ^(LKTag * tag){
            
            @normally(self);
            
            [self.shareTools hideTools];

            [self _beginComment:tag];
        };
        
        
        // 回复某人
        cell.replyAction = ^(LKTag * tag, LKComment * comment){
        
            @normally(self);

            [self.shareTools hideTools];

            if (UI_IS_IPHONE4) {
                if(![LKLoginViewIp4Controller needLoginOnViewController:self]){
                    
                    [self.inputView resignFirstResponder];
                    
                    LKTagCommentsViewController *comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
                    
                    // 传递发布者模型数据
                    comments.publisher = self.post;
                    // 设置代理
                    comments.delegate = self;
                    
                    //                [comments showInViewController:self];
                    [self.navigationController pushViewController:comments animated:YES];
                    
                    if (LKLocalUser.singleton.user.id.integerValue != comment.user.id.integerValue) {
                        
                        //                    [comments replyUserAction:comment.user];
                        [comments performSelector:@selector(replyUserAction:) withObject:comment.user afterDelay:1];
                    }
                    
                    //                [self hideMoreButton:YES];
                    
                    comments.willHide = ^(){
                        
                        //                    [self hideMoreButton:NO];
                        [self.tableView reloadData];
                        
                    };
                }
            } else {
                if(![LKLoginViewController needLoginOnViewController:self]){
                    
                    [self.inputView resignFirstResponder];
                    
                    LKTagCommentsViewController *comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
                    
                    // 传递发布者模型数据
                    comments.publisher = self.post;
                    // 设置代理
                    comments.delegate = self;
                    
                    //                [comments showInViewController:self];
                    [self.navigationController pushViewController:comments animated:YES];
                    
                    if (LKLocalUser.singleton.user.id.integerValue != comment.user.id.integerValue) {
                        
                        //                    [comments replyUserAction:comment.user];
                        [comments performSelector:@selector(replyUserAction:) withObject:comment.user afterDelay:1];
                    }
                    
                    //                [self hideMoreButton:YES];
                    
                    comments.willHide = ^(){
                        
                        //                    [self hideMoreButton:NO];
                        [self.tableView reloadData];
                        
                    };
                }
            }
        };
        
        // 显示评论列表页
        cell.showMoreAction = ^(LKTag * tag){
          
            @normally(self);

            [self.shareTools hideTools];

            if (UI_IS_IPHONE4) {
                if(![LKLoginViewController needLoginOnViewController:self]){
                    
                    [self.inputView resignFirstResponder];
                    
                    LKTagCommentsViewController *comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
                    
                    //                [comments showInViewController:self];
                    [self.navigationController pushViewController:comments animated:YES];
                    
                    [self hideMoreButton:YES];
                    
                    comments.willHide = ^(){
                        
                        [self hideMoreButton:NO];
                        [self.tableView reloadData];
                        
                    };
                }
            } else {
                if(![LKLoginViewController needLoginOnViewController:self]){
                    
                    [self.inputView resignFirstResponder];
                    
                    LKTagCommentsViewController *comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
                    
                    //                [comments showInViewController:self];
                    [self.navigationController pushViewController:comments animated:YES];
                    
                    [self hideMoreButton:YES];
                    
                    comments.willHide = ^(){
                        
                        [self hideMoreButton:NO];
                        [self.tableView reloadData];
                        
                    };
                }
            }
        };
        
        return cell;
    }

    ERROR(@"cell is nil...");
    return nil;
}

-(void) newTagAnimation {
    if (!self.blackMask) {
        self.blackMask = UIView.view;
        self.blackMask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.header.ADD(self.blackMask);
    }
    
    self.blackMask.frame = self.header.bounds;
    self.blackMask.alpha = 0;
    
    LCUILabel * label = [[LCUILabel alloc] init];
    label.text = @"+1";
    label.font = [UIFont fontWithName:@"AvenirNext-Bold" size:60];
    label.textColor = [UIColor whiteColor];
    label.FIT();
    label.viewCenterX = self.header.viewMidWidth;
    label.viewCenterY = self.header.viewMidHeight;
    label.alpha = 0;
    label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
    self.header.ADD(label);
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        label.alpha = 1;
        label.transform = CGAffineTransformIdentity;
        self.blackMask.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
            
            label.alpha = 0;
            self.blackMask.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [label removeFromSuperview];
            
        }];
    }];
    
}


-(void) hideMoreButton:(BOOL)hide
{
    UIButton * button = self.header.FIND(1002);
    UIButton * button1 = self.header.FIND(1003);
    
    LC_FAST_ANIMATIONS(0.25, ^{
       
        button.alpha = hide ? 0 : 1;
        button1.alpha = hide ? 0 : 1;
    });
}


// 估计以后还得改
- (UIImage *)buildShareImage:(NSInteger)shareIndex {
    
    if (self.isBackgroundImageGIF) {
        return nil;
    }
    
    UIImage *image = [LCUIImageCache.singleton imageWithKey:self.bigContentURL];
    if (!image) {
        image = self.header.backgroundView.image;
    }
    
    if (image.size.width < 640) {
        image = [image scaleToBeWidth:640];
    }
    
    if (image.size.width > 1242) {
        image = [image scaleToBeWidth:1242];
    }
    
    UIView *bottomView = UIView.view;
    
    CGFloat proportion = (image.size.width / 640);
    CGFloat layoutScale = (image.size.width / 414);
    CGFloat headWidth = 94 * proportion;
    
    // 只是为了补色
    UIView *backView = UIView.view;
    backView.viewFrameY = headWidth / 2;
    backView.viewFrameWidth = image.size.width;
    backView.viewFrameHeight = headWidth / 2;
    backView.backgroundColor = LKColor.backgroundColor;
    bottomView.ADD(backView);
    
    // 头像下面的view
    UIView *cornerRadiusView = UIView.view;
    cornerRadiusView.viewFrameX = 21 * layoutScale;
    cornerRadiusView.viewFrameY = 0;
    cornerRadiusView.viewFrameWidth = headWidth;
    cornerRadiusView.viewFrameHeight = headWidth;
    cornerRadiusView.cornerRadius = headWidth / 2;
    cornerRadiusView.backgroundColor = LKColor.backgroundColor;
    bottomView.ADD(cornerRadiusView);
    
    // 用户头像
    LCUIImageView *imageView = LCUIImageView.view;
    imageView.viewFrameWidth = headWidth - 4 * layoutScale;
    imageView.viewFrameHeight = headWidth - 4 * layoutScale;
    imageView.viewFrameX = 21 * layoutScale + 2 * layoutScale;
    imageView.viewFrameY = 2 * proportion;
    imageView.url = self.post.user.avatar;
//    [imageView sd_setImageWithURL:[NSURL URLWithString:self.post.user.avatar] placeholderImage:nil];
    imageView.cornerRadius = imageView.viewMidHeight;
    imageView.backgroundColor = [UIColor whiteColor];
    bottomView.ADD(imageView);
    
    // 昵称
    LCUILabel *nameLabel = LCUILabel.view;
    nameLabel.viewFrameX = imageView.viewRightX + 10 * layoutScale;
    nameLabel.viewFrameY = 9 * layoutScale + headWidth / 2;
    nameLabel.viewFrameWidth = 10000;
    nameLabel.viewFrameHeight = 22 * layoutScale + 2;
    nameLabel.font = LK_FONT_B(14 * layoutScale);
    nameLabel.textColor = LC_RGB(51, 51, 51);
    nameLabel.text = [NSString stringWithFormat:@"%@   %@ likes" ,self.post.user.name ,self.post.user.likes];
    bottomView.ADD(nameLabel);
    
    
    // 分享图片的标签
    LKShareTagsView *tagsView = LKShareTagsView.view;
    tagsView.backgroundColor = LKColor.backgroundColor;
    tagsView.proportion = proportion;
    tagsView.viewFrameY = imageView.viewBottomY;
    tagsView.viewFrameX = 1 * layoutScale;
    tagsView.viewFrameWidth = image.size.width * 640 / 414 - 42 * layoutScale;
    tagsView.tags = self.tagsListModel.tags;
    bottomView.ADD(tagsView);
    
    // 设置标签颜色
    for (LKTagItemView *item in tagsView.subviews) {
        
        item.backgroundColor = [LKColor.color colorWithAlphaComponent:1];
        item.tagLabel.textColor = [UIColor whiteColor];
        item.likesLabel.textColor = [UIColor whiteColor];
    }
    
    
    // 底部view
    UIView *belowView = UIView.view;
    belowView.viewFrameY = tagsView.viewBottomY;
    belowView.viewFrameWidth = image.size.width;
    belowView.viewFrameHeight = 79 * layoutScale;
    belowView.backgroundColor = [UIColor whiteColor];
    bottomView.ADD(belowView);
    
    
    // 二维码
    LCUIImageView *qrCodeView = LCUIImageView.view;
    qrCodeView.viewFrameWidth = 59 * layoutScale;
    qrCodeView.viewFrameHeight = 59 * layoutScale;
    qrCodeView.viewFrameX = belowView.viewFrameWidth - (21 + 9 + 59 + 53) * layoutScale;
    qrCodeView.viewFrameY = 10 * layoutScale;
    qrCodeView.image = [UIImage imageNamed:@"QRCode.png" useCache:YES];
    belowView.ADD(qrCodeView);
    
    // logo
    LCUIImageView *logoView = LCUIImageView.view;
    logoView.viewFrameWidth = 53 * layoutScale;
    logoView.viewFrameHeight = 53 * layoutScale;
    logoView.viewFrameX = belowView.viewFrameWidth - (21 + 53) * layoutScale;
    logoView.viewFrameY = 13 * layoutScale;
    logoView.image = [UIImage imageNamed:@"like_icon.png" useCache:YES];
    belowView.ADD(logoView);
    
    // 添加特色图片
    LCUIImageView *interestView = LCUIImageView.view;
    interestView.viewFrameWidth = 159 * layoutScale;
    interestView.viewFrameHeight = 47 * layoutScale;
    interestView.viewFrameX = cornerRadiusView.viewFrameX;
    interestView.viewFrameY = 16 * layoutScale;
    belowView.ADD(interestView);
    
    NSArray *interestArray = @[@"高达", @"狗", @"旅行", @"猫", @"美食", @"喷漆", @"摄影", @"游戏", @"手办", @"变形金刚", @"钢铁侠", @"星球大战"];
    
    UIImage *interestImage = nil;
    for (LKTag *tag in self.tagsListModel.tags) {
        
        for (NSString *str in interestArray) {
            
            NSRange range = [tag.tag rangeOfString:str];
            if (range.length) {
                
                interestImage = [self getInterestImageWithTagArray:interestArray tag:tag];
                break;
            }
        }
        
        if (interestImage) {
            
            break;
        }
    }
    
    if (interestImage == nil) {
        
        interestImage = [UIImage imageNamed:@"photography.png"];
    }
    
    interestView.image = interestImage;
    
    bottomView.viewFrameHeight = belowView.viewBottomY;
    bottomView.viewFrameWidth = image.size.width;
    
    UIView *background = UIView.view;
    background.backgroundColor = [UIColor whiteColor];
    background.viewFrameWidth = bottomView.viewFrameWidth;
    background.viewFrameHeight = bottomView.viewFrameHeight;
    background.viewFrameY = headWidth / 2;
    [bottomView insertSubview:background atIndex:0];
    
    
    UIGraphicsBeginImageContextWithOptions(bottomView.frame.size, NO, 1);
    
    [bottomView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *tagImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    image = [image addMaskImage:tagImage
                      imageSize:LC_SIZE(image.size.width, image.size.height + tagImage.size.height - headWidth / 2)
                         inRect:LC_RECT(0, image.size.height - headWidth / 2, bottomView.viewFrameWidth, bottomView.viewFrameHeight)];
    
    return image;
}

/**
 *  根据不同的兴趣返回不同的图片
 */
- (UIImage *)getInterestImageWithTagArray:(NSArray *)tagArray tag:(LKTag *)tag {
    
    // 高达
    NSArray *gundam = @[@"高达", @"Gundam", @"Gunpla", @"RG", @"MG", @"HG", @"强袭", @"高达模型"];
    // 狗
    NSArray *dog = @[@"汪星人", @"汪", @"狗"];
    // 旅行
    NSArray *travel = @[@"旅行", @"吉他", @"音乐", @"艺术", @"旅游"];
    // 猫
    NSArray *cat = @[@"喵星人", @"猫", @"喵"];
    // 美食
    NSArray *delicious = @[@"美食", @"吃货", @"好吃的", @"吃吃吃", @"饿了"];
    // 喷漆
    NSArray *lacquer = @[@"喷漆", @"上色", @"喷涂", @"改色", @"涂装", @"旧化"];
    // 摄影
    NSArray *photography = @[@"风景", @"海", @"旅行"];
    // 游戏
    NSArray *game = @[@"PS4", @"XBOX", @"游戏", @"GTA", @"数码", @"索尼大法好", @"索大好"];
    // 手办
    NSArray *gk = @[@"手办", @"粘土人", @"粘土", @"舰娘", @"初音", @"动漫", @"漫画"];
    // 变形金刚
    NSArray *transformer = @[@"变形金刚", @"擎天柱", @"大力神", @"大黄蜂", @"TF", @"汽车人", @"transformers", @"威震天"];
    // 钢铁侠
    NSArray *ironMan = @[@"钢铁侠", @"美国队长", @"IRON MAN", @"复仇者联盟", @"绿巨人", @"漫威"];
    // 星球大战
    NSArray *starWar = @[@"星球大战", @"STAR WARS", @"STARWARS", @"星战"];
    
    if ([tag.tag rangeOfString:tagArray[0]].length) {
        
        for (NSString *str in gundam) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"gundam.png"];
            }
        }
    }
    
    if ([tag.tag rangeOfString:tagArray[1]].length) {
        
        for (NSString *str in dog) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"dog.png"];
            }
        }
    }

    if ([tag.tag rangeOfString:tagArray[2]].length) {
        
        for (NSString *str in travel) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"travel.png"];
            }
        }
    }

    if ([tag.tag rangeOfString:tagArray[3]].length) {
        
        for (NSString *str in cat) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"cat.png"];
            }
        }
    }

    if ([tag.tag rangeOfString:tagArray[4]].length) {
        
        for (NSString *str in delicious) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"delicious.png"];
            }
        }
    }

    if ([tag.tag rangeOfString:tagArray[5]].length) {
        
        for (NSString *str in lacquer) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"lacquer.png"];
            }
        }
    }

    if ([tag.tag rangeOfString:tagArray[6]].length) {
        
        for (NSString *str in photography) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"photography.png"];
            }
        }
    }

    if ([tag.tag rangeOfString:tagArray[7]].length) {
        
        for (NSString *str in game) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"game.png"];
            }
        }
    }
    
    if ([tag.tag rangeOfString:tagArray[8]].length) {
        
        for (NSString *str in gk) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"gk.png"];
            }
        }
    }
    
    if ([tag.tag rangeOfString:tagArray[9]].length) {
        
        for (NSString *str in transformer) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"transformer.png"];
            }
        }
    }
    
    if ([tag.tag rangeOfString:tagArray[10]].length) {
        
        for (NSString *str in ironMan) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"ironMan.png"];
            }
        }
    }
    
    if ([tag.tag rangeOfString:tagArray[11]].length) {
        
        for (NSString *str in starWar) {
            
            if ([tag.tag rangeOfString:str].length) {
                
                return [UIImage imageNamed:@"starWar.png"];
            }
        }
    }
    
    return nil;
}

-(void) reloadDataAndUpdate
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return 54;
    }
    
    LKTag * tag = self.tagsListModel.tags[indexPath.row];
    CGFloat height = [LKPostDetailCell height:tag];
    if (indexPath.row == self.tagsListModel.tags.count - 1) {
        height += 5;
    }
    
    return height;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.shareTools hideTools];

    if (indexPath.section == 0) {
        
        [LKUserCenterViewController pushUserCenterWithUser:self.post.user navigationController:self.navigationController];
    }
    else{
        

    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.inputView resignFirstResponder];
    
    [self.header handleScrollDidScroll:scrollView];
}

#pragma mark - <RMPZoomTransitionAnimating>

- (UIImageView *)transitionSourceImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.header.backgroundView.image];
    imageView.contentMode = self.header.backgroundView.contentMode;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    imageView.frame = self.header.backgroundView.frame;
    return imageView;
}

- (UIColor *)transitionSourceBackgroundColor
{
    return self.view.backgroundColor;
}

- (CGRect)transitionDestinationImageViewFrame
{
    return self.header.backgroundView.frame;
}

#pragma mark - <RMPZoomTransitionDelegate>

- (void)zoomTransitionAnimator:(RMPZoomTransitionAnimator *)animator
         didCompleteTransition:(BOOL)didComplete
      animatingSourceImageView:(UIImageView *)imageView
{
    self.header.backgroundView.image = imageView.image;
}

@end
