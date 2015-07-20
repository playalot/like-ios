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
#import "LKTagLikesViewController.h"
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

@interface LKPostDetailViewController ()<UITableViewDataSource,UITableViewDelegate,JTSImageViewControllerDismissalDelegate,UINavigationControllerDelegate,UIViewControllerTransitioningDelegate>

LC_PROPERTY(strong) BLKDelegateSplitter * delegateSplitter;
LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(strong) LCUIPullLoader * pullLoader;


LC_PROPERTY(strong) LCUIImageView * userHead;
LC_PROPERTY(strong) LCUILabel * userName;
LC_PROPERTY(strong) LCUILabel * postTime;


LC_PROPERTY_MODEL(LKPostTagsDetailModel, tagsListModel);

LC_PROPERTY(copy) NSString * bigContentURL;
LC_PROPERTY(strong) AFHTTPRequestOperation * bigImageRequestOperation;

LC_PROPERTY(strong) LKPresentAnimation * animator;

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
    [super viewWillAppear:animated];
    
    [self setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated];

    
    //
    [self.header.headImageView removeFromSuperview];
    [self.header.nameLabel removeFromSuperview];
    [self.header.icon removeFromSuperview];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    ((LCUINavigationController *)self.navigationController).animationHandler = ^id(UINavigationControllerOperation operation, UIViewController * fromVC, UIViewController * toVC){
//        
//        if (operation == UINavigationControllerOperationPop) {
//            
//            return [[LKPopAnimation alloc] init];
//        }
//        
//        return nil;
//    };
    
    
    if (self.tableView.viewFrameY != 0) {
    
        self.tableView.pop_springBounciness = 10;
        self.tableView.pop_springSpeed = 10;
        self.tableView.pop_spring.center = LC_POINT(self.tableView.viewCenterX, self.tableView.viewCenterY - 30);
        self.tableView.pop_spring.alpha = 1;
    }
    
    
    if (!self.bigContentURL) {
     
        // Big image...
        [self loadBigImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //((LCUINavigationController *)self.navigationController).animationHandler = nil;
    
    [self.inputView resignFirstResponder];
}

#pragma mark -

//- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
//{
//    if (operation == UINavigationControllerOperationPop) {
//        return [[LKPopAnimation alloc] init];
//    }
//    
//    return nil;
//}

#pragma mark -

-(instancetype) initWithPost:(LKPost *)post
{
    if (self = [super init]) {
        
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

-(void) setPresendModelAnimationOpen
{
    self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;

    self.animator = [[LKPresentAnimation alloc] init];
    
    self.navigationController.transitioningDelegate = self.animator;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tagsListModel = LKPostTagsDetailModel.new;
    
    @weakly(self);
    
    self.tagsListModel.associatedTags = self.post.tags;
    
    self.tagsListModel.requestFinished = ^(LKHttpRequestResult * result , NSString * error){
        
        @normally(self);
        
        [self.pullLoader endRefresh];

        if (error) {
            [self showTopMessageErrorHud:error];
        }
        else{
            
            [self.tableView reloadData];
        }
    };
    
    
    // Load...
    [self.tagsListModel loadDataWithPostID:self.post.id getMore:NO];
}

-(void) buildUI
{
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
    
    {
        CGSize size = [LKUIKit parsingImageSizeWithURL:self.post.content];
        
        // Header
        if (size.width > LC_DEVICE_WIDTH) {
            
            size.height = LC_DEVICE_WIDTH / size.width * size.height;
            size.width = LC_DEVICE_WIDTH;
        }

        
        self.header = [[LKHomepageHeader alloc] initWithFrame:CGRectMake(0.0, 0, CGRectGetWidth(self.view.frame), size.height) maxHeight:size.height minHeight:44];
        self.header.clipsToBounds = YES;
        self.header.scrollView = self.tableView;
        self.header.backgroundView.showIndicator = YES;
        self.header.backgroundView.url = self.post.content;
        self.header.backgroundView.frame = CGRectMake(0, 0, size.width, size.height);
        self.header.maskView.backgroundColor = [UIColor clearColor];
        
        SquareCashStyleBehaviorDefiner * behaviorDefiner = [[SquareCashStyleBehaviorDefiner alloc] init];
        [behaviorDefiner addSnappingPositionProgress:0.0 forProgressRangeStart:0.0 end:0.5];
        [behaviorDefiner addSnappingPositionProgress:1.0 forProgressRangeStart:0.5 end:1.0];
        behaviorDefiner.snappingEnabled = NO;
        behaviorDefiner.elasticMaximumHeightAtTop = NO;
        self.header.behaviorDefiner = behaviorDefiner;
        
        self.delegateSplitter = [[BLKDelegateSplitter alloc] initWithFirstDelegate:behaviorDefiner secondDelegate:self];
        self.tableView.delegate = (id<UITableViewDelegate>)self.delegateSplitter;
        
        [self.view addSubview:self.header];
        
        self.tableView.contentInset = UIEdgeInsetsMake(self.header.maximumBarHeight, 0.0, 0.0, 0.0);
        
        @weakly(self);
        
        self.header.backgroundAction = ^(id value){
            
            @normally(self);
            
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
                
                //if (self.bigContentURL) {
                
                NSString * content = nil;
                
                if (self.post.content) {
                    
                    NSArray * contents = [self.post.content componentsSeparatedByString:@"?"];
                    
                    if (contents.count) {
                        content = [contents[0] stringByAppendingString:@"?imageView2/4/q/85"];
                    }
                }
                
                info.imageURL = [NSURL URLWithString:content];
                //                        }
                //                        else{
                //
                //                        }
                
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
        
        
        
        //
        LCUIButton * backButton = LCUIButton.view;
        backButton.viewFrameWidth = 80;
        backButton.viewFrameHeight = 80;
        backButton.viewFrameY = -17;
        backButton.viewFrameX = -15;
        backButton.buttonImage = [UIImage imageNamed:@"NavigationBarBack.png" useCache:YES];
        backButton.showsTouchWhenHighlighted = YES;
        [backButton addTarget:self action:@selector(_dismissAction) forControlEvents:UIControlEventTouchUpInside];
        backButton.tag = 1002;
        [self.header addSubview:backButton];
        
        
        LCUIButton * moreButton = LCUIButton.view;
        moreButton.viewFrameWidth = 50 / 3 + 40;
        moreButton.viewFrameHeight = 11 / 3 + 20;
        moreButton.viewFrameX = LC_DEVICE_WIDTH - moreButton.viewFrameWidth;
        moreButton.viewFrameY = 10;
        moreButton.buttonImage = [UIImage imageNamed:@"NavigationBarMore.png" useCache:YES];
        moreButton.showsTouchWhenHighlighted = YES;
        [moreButton addTarget:self action:@selector(_moreAction) forControlEvents:UIControlEventTouchUpInside];
        moreButton.tag = 1003;
        [self.header addSubview:moreButton];
    }
    
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
        }
        else{
            
            [self showTopMessageErrorHud:LC_LO(@"该标签已存在")];
        }
    };
    
    
    
    self.pullLoader = [LCUIPullLoader pullLoaderWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleFooter];
    
    self.pullLoader.beginRefresh = ^(LCUIPullLoaderDiretion diretion){
      
        @normally(self);
        
        if (diretion == LCUIPullLoaderDiretionBottom) {
            
            [self.tagsListModel loadDataWithPostID:self.post.id getMore:YES];
        }
    };
}

#pragma mark -

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

#pragma mark -

-(void) openCommentsView:(LKTag *)tag
{
    [self _beginComment:tag];
}

#pragma mark -

-(BOOL) _checkTag:(NSString *)tag onTags:(NSArray *)onTags
{
    NSArray * tmp = onTags;
    
    if (onTags.count == 0) {
        
        tmp = self.tagsListModel.tags;
    }
    
    for (LKTag * oTag in tmp) {
        
        if ([oTag.tag isEqualToString:tag]) {
            
            return NO;
        }
    }
    
    return YES;
}

-(void) _addTag:(NSString *)tag onPost:(LKPost *)post
{
    if([LKLoginViewController needLoginOnViewController:self.navigationController]){
        
        return;
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
            LKTag * tag = [LKTag objectFromDictionary:result.json[@"data"]];
            
            if (!tag) {
                
                // input view...
                [self.inputView resignFirstResponder];
                self.inputView.textField.text = @"";
                return;
            }
            
            tag.user = LKLocalUser.singleton.user;
            
            [post.tags insertObject:tag atIndex:0];
            [self.tagsListModel.tags insertObject:tag atIndex:0];
            
            post.user.likes = @(post.user.likes.integerValue + 1);
            
            [self.tableView reloadData];
            
            // input view...
            [self.inputView resignFirstResponder];
            
            //
            self.inputView.textField.text = @"";
        }
        
    }];
}


-(void) _dismissAction
{
    [self dismissOrPopViewController];
}

-(void) _moreAction
{
    [self.inputView resignFirstResponder];
    
    @weakly(self);

    if (self.post.user.id.integerValue == LKLocalUser.singleton.user.id.integerValue) {
        
        [LKActionSheet showWithTitle:LC_LO(@"更多") buttonTitles:@[LC_LO(@"举报"),LC_LO(@"删除"),LC_LO(@"保存图片")] didSelected:^(NSInteger index) {
            
            @normally(self);

            if (index == 0) {
                
                // 举报
                [self _report];
            }
            else if (index == 1){
                
                // 删除
                [self _delete];
            }
            else if (index == 2){
                
                if (self.header.backgroundView.image) {
                    
                    [LKPhotoAlbum saveImage:self.header.backgroundView.image showTip:YES];
                }
            }

            
        }];
    }
    else{
        
        [LKActionSheet showWithTitle:LC_LO(@"更多") buttonTitles:@[LC_LO(@"举报"),LC_LO(@"保存图片")] didSelected:^(NSInteger index) {
            
            @normally(self);

            if (index == 0) {
                
                // 举报
                [self _report];
            }
            else if (index == 1){
                
                if (self.header.backgroundView.image) {
                    
                    [LKPhotoAlbum saveImage:self.header.backgroundView.image showTip:YES];
                }
            }
            
        }];
    }
}

#pragma mark -

-(void) loadBigImage
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"post/%@",self.post.id]].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            if ([self.post.content isEqualToString:result.json[@"data"][@"content"]]) {
                return;
            }
            
            self.post.place = [result.json[@"data"][@"place"] isKindOfClass:[NSString class]] ? result.json[@"data"][@"place"] : nil;
            self.post.timestamp = result.json[@"data"][@"created"];
            //self.post.content = result.json[@"data"][@"content"];
            self.bigContentURL = result.json[@"data"][@"content"];
            
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

-(void) _report
{
    if ([LKLoginViewController needLoginOnViewController:self.navigationController]) {
        return;
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
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    //
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

-(void) _beginComment:(LKTag *)tag
{
    // check
    if(![LKLoginViewController needLoginOnViewController:self]){
        
        [self.inputView resignFirstResponder];
        
        LKTagCommentsViewController * comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
        
        [comments showInViewController:self];
        [comments inputBecomeFirstResponder];
        
        [self hideMoreButton:YES];
        
        comments.willHide = ^(){
            
            [self hideMoreButton:NO];
            [self.tableView reloadData];
            
        };
    }

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
     
        LCUITableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"User" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            
            configurationCell.backgroundColor = [UIColor clearColor];
            configurationCell.contentView.backgroundColor = [UIColor clearColor];
            configurationCell.selectionStyle = UITableViewCellSelectionStyleNone;

            
            self.userHead = LCUIImageView.view;
            self.userHead.viewFrameX = 10;
            self.userHead.viewFrameY = 10;
            self.userHead.viewFrameWidth = 33;
            self.userHead.viewFrameHeight = 33;
            self.userHead.cornerRadius = 33. / 2.;
            self.userHead.backgroundColor = [UIColor lightGrayColor];
            configurationCell.ADD(self.userHead);
            
            
            self.userName = LCUILabel.view;
            self.userName.viewFrameY = 11;
            self.userName.viewFrameX = self.userHead.viewRightX + 10;
            self.userName.viewFrameWidth = LC_DEVICE_WIDTH - self.userName.viewFrameX - 75;
            self.userName.viewFrameHeight = 15;
            self.userName.textAlignment = UITextAlignmentLeft;
            self.userName.font = LK_FONT(13);
            self.userName.lineBreakMode = NSLineBreakByTruncatingMiddle;
            self.userName.textColor = LC_RGB(51, 51, 51);
            configurationCell.ADD(self.userName);
            
            
            self.postTime = LCUILabel.view;
            self.postTime.viewFrameY = self.userName.viewBottomY + 5;
            self.postTime.viewFrameX = self.userHead.viewRightX + 10;
            self.postTime.viewFrameWidth = self.userName.viewFrameWidth;
            self.postTime.viewFrameHeight = 14;
            self.postTime.textAlignment = UITextAlignmentLeft;
            self.postTime.font = LK_FONT(12);
            self.postTime.lineBreakMode = NSLineBreakByTruncatingMiddle;
            self.postTime.textColor = LC_RGB(140, 133, 126);
            configurationCell.ADD(self.postTime);
            
            
            LKShareTools * tools = LKShareTools.view;
            tools.tag = 1003;
            configurationCell.ADD(tools);
            
        }];
        
        
        LKShareTools * tools = cell.FIND(1003);
        
        @weakly(self);
        
        tools.willShow = ^(id value){
            
            @normally(self);
            
            LC_FAST_ANIMATIONS(0.25, ^{
                
                self.userName.alpha = 0;
                self.userHead.alpha = 0;
                self.postTime.alpha = 0;
                
            });
        };
        
        tools.willHide = ^(id value){
            
            @normally(self);
            
            LC_FAST_ANIMATIONS(0.25, ^{
                
                self.userName.alpha = 1;
                self.userHead.alpha = 1;
                self.postTime.alpha = 1;
                
            });
        };
        
        tools.willShareImage = ^UIImage *(NSInteger index){
            
            @normally(self);
            
            return [self buildShareImage:index];
        };
        
        
        self.userHead.url = self.post.user.avatar;
        self.userName.text = LC_NSSTRING_FORMAT(@"%@ %@ likes", self.post.user.name, self.post.user.likes);
        
        NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:self.userName.text];
        [attString addAttribute:NSFontAttributeName value:LK_FONT_B(13) range:[self.userName.text rangeOfString:self.post.user.name]];
        
        self.userName.attributedText = attString;
        
        self.postTime.text = [NSString stringWithFormat:@"%@ %@ %@", [LKTime dateNearByTimestamp:self.post.timestamp], self.post.place ? LC_LO(@"来自") : @"", self.post.place ? self.post.place : @""];
        
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
            
            self.userName.text = LC_NSSTRING_FORMAT(@"%@ %@ likes", self.post.user.name, self.post.user.likes);
            
            NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:self.userName.text];
            [attString addAttribute:NSFontAttributeName value:LK_FONT_B(13) range:[self.userName.text rangeOfString:self.post.user.name]];
            
            self.userName.attributedText = attString;
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
            

        };
        
        
        // 开始评论
        cell.commentAction = ^(LKTag * tag){
            
            @normally(self);
            
            [self _beginComment:tag];
        };
        
        
        // 回复某人
        cell.replyAction = ^(LKTag * tag, LKComment * comment){
        
            @normally(self);

            if(![LKLoginViewController needLoginOnViewController:self]){
                
                [self.inputView resignFirstResponder];
                
                LKTagCommentsViewController * comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
                
                [comments showInViewController:self];
                
                if (LKLocalUser.singleton.user.id.integerValue != comment.user.id.integerValue) {
                    
                    [comments replyUserAction:comment.user];
                }

                [self hideMoreButton:YES];
                
                comments.willHide = ^(){
                    
                    [self hideMoreButton:NO];
                    [self.tableView reloadData];
                    
                };
            }
        };
        
        // 显示评论列表页
        cell.showMoreAction = ^(LKTag * tag){
          
            @normally(self);

            if(![LKLoginViewController needLoginOnViewController:self]){

                [self.inputView resignFirstResponder];

                LKTagCommentsViewController * comments = [[LKTagCommentsViewController alloc] initWithTag:tag];
                
                [comments showInViewController:self];
                
                [self hideMoreButton:YES];
                
                comments.willHide = ^(){
                    
                    [self hideMoreButton:NO];
                    [self.tableView reloadData];
                    
                };
            }
        };
        
        return cell;
    }

    ERROR(@"cell is nil...");
    return nil;
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
-(UIImage *) buildShareImage:(NSInteger)shareIndex
{
//
//    
//    NSInteger i = 0;
//    
//    for (LKTag * tag in self.post.tags) {
//        
//        i += tag.likes.integerValue;
//    }
//    
//    
//    NSString * markString = nil;
//    
//    if (i != 0) {
//        markString = [NSString stringWithFormat:@"like - 你的新玩具\n%@ tags, %@ likes, %@", @(self.post.tags.count), @(i), self.post.user.name];
//    }
//    else{
//        markString = [NSString stringWithFormat:@"like - 你的新玩具\n%@", self.post.user.name];
//    }
//    
//    
//    CGSize size = [markString sizeWithFont:LK_FONT(20) byHeight:9999];
//    
//    
//    if (shareIndex == 3) {
//        
//        CGRect rect = CGRectMake(10, image.size.height - size.height - 10, size.width, size.height);
//        image = [image addMarkString:markString inRect:rect color:[UIColor whiteColor] font:LK_FONT(20) textAlignment:UITextAlignmentLeft];
//    }
//    else{
//        
//        CGRect rect = CGRectMake(image.size.width - size.width - 10, image.size.height - size.height - 10, size.width, size.height);
//        image = [image addMarkString:markString inRect:rect color:[UIColor whiteColor] font:LK_FONT(20) textAlignment:UITextAlignmentRight];
//    }
    
    
    UIImage * image = [LCUIImageCache.singleton imageWithKey:self.bigContentURL];
    
    if (!image) {
        
        image = [LCUIImageCache.singleton imageWithKey:self.post.content];
    }
    
    if (image.size.width < 640) {
        
        image = [image scaleToBeWidth:640];
    }
    
    if (image.size.width > 1242) {
        
        image = [image scaleToBeWidth:1242];
    }
    
    UIView * bottomView = UIView.view;
    
    CGFloat proportion = (image.size.width / 640);
    CGFloat headWidth = 90 * proportion;
    
    
    UIView * cornerRadiusView = UIView.view;
    cornerRadiusView.viewFrameX = 20 * proportion;
    cornerRadiusView.viewFrameY = 0;
    cornerRadiusView.viewFrameWidth = headWidth;
    cornerRadiusView.viewFrameHeight = headWidth;
    cornerRadiusView.cornerRadius = headWidth / 2;
    cornerRadiusView.backgroundColor = [UIColor whiteColor];
    bottomView.ADD(cornerRadiusView);
    
    
    LCUIImageView * imageView = LCUIImageView.view;
    imageView.viewFrameWidth = headWidth - 10 * proportion;
    imageView.viewFrameHeight = headWidth - 10 * proportion;
    imageView.viewFrameX = 20 * proportion + 5 * proportion;
    imageView.viewFrameY = 5 * proportion;
    imageView.url = self.post.user.avatar;
    imageView.cornerRadius = imageView.viewMidHeight;
    imageView.backgroundColor = [UIColor whiteColor];
    bottomView.ADD(imageView);
    
    
    
    LCUILabel * nameLabel = LCUILabel.view;
    nameLabel.viewFrameX = imageView.viewRightX + 10 * proportion;
    nameLabel.viewFrameY = 10 * proportion + headWidth / 2;
    nameLabel.viewFrameWidth = 10000;
    nameLabel.viewFrameHeight = 22 * proportion + 2;
    nameLabel.font = LK_FONT(22 * proportion);
    nameLabel.textColor = LC_RGB(51, 51, 51);
    nameLabel.text = [NSString stringWithFormat:@"%@ · %@ likes" ,self.post.user.name ,self.post.user.likes];
    bottomView.ADD(nameLabel);
    
    
    LKShareTagsView * tagsView = LKShareTagsView.view;
    tagsView.proportion = proportion;
    tagsView.viewFrameY = imageView.viewBottomY + 10 * proportion;
    tagsView.viewFrameX = 20 * proportion;
    tagsView.viewFrameWidth = image.size.width - 40 * proportion;
    tagsView.tags = self.tagsListModel.tags;
    bottomView.ADD(tagsView);

    
    bottomView.viewFrameHeight = tagsView.viewBottomY + 10 * proportion;
    bottomView.viewFrameWidth = image.size.width;
    
    
    UIView * background = UIView.view;
    background.backgroundColor = [UIColor whiteColor];
    background.viewFrameWidth = bottomView.viewFrameWidth;
    background.viewFrameHeight = bottomView.viewFrameHeight;
    background.viewFrameY = headWidth / 2;
    [bottomView insertSubview:background atIndex:0];
    
    
    UIGraphicsBeginImageContextWithOptions(bottomView.frame.size, NO, 1);
    
    [bottomView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * tagImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
                                
    image = [image addMaskImage:tagImage
                      imageSize:LC_SIZE(image.size.width, image.size.height + tagImage.size.height - headWidth / 2)
                         inRect:LC_RECT(0, image.size.height - headWidth / 2, bottomView.viewFrameWidth, bottomView.viewFrameHeight)];
    
    
    UIImage * icon = [[UIImage imageNamed:@"LikeIconSmall.png" useCache:NO] scaleToBeWidth:33 * proportion];
    
    image = [image addMaskImage:icon
                      imageSize:image.size
                         inRect:LC_RECT(image.size.width - icon.size.width - 20, 20, icon.size.width, icon.size.height)];
    
    return image;
}

-(void) reloadDataAndUpdate
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return 33 + 20;
    }
    
    LKTag * tag = self.tagsListModel.tags[indexPath.row];
    
    return [LKPostDetailCell height:tag];
}

//- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section != 0) {
//     
//        cell.alpha = 0;
//        
//        LC_FAST_ANIMATIONS(0.25, ^{
//            
//            cell.alpha = 1;
//        });
//    }
//}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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


@end
