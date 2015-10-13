//
//  LKTagCommentsViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/5/28.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKTagCommentsViewController.h"
#import "LKTagCommentCell.h"
#import "LKTagsView.h"
#import "LKTime.h"
#import "LKInputView.h"
#import "LKLocationManager.h"
#import "LCUIKeyBoard.h"
#import "LKLikesPage.h"
#import "LKUserCenterViewController.h"
#import "UIImageView+WebCache.h"

#define iconWH 30

@interface LKTagCommentsViewController () <UITableViewDataSource,UITableViewDelegate>

LC_PROPERTY(strong) LKTag * tagValue;

LC_PROPERTY(strong) LCUILabel * header;
LC_PROPERTY(strong) LCUIBlurView * blur;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(strong) LKUser * replyUser;

LC_PROPERTY(strong) NSMutableArray * datasource;

LC_PROPERTY(strong) LKLocationManager * locationManager;

LC_PROPERTY(strong) NSNumber * canFirstResponder;
/**
 *  用于显示给标签点赞的用户
 */
@property (nonatomic, strong) UIScrollView *tagUserView;
/**
 *  存放给标签点赞的用户的数组
 */
@property (nonatomic, strong) NSMutableArray *tagUsers;
/**
 *  点赞用户的头像X值
 */
@property (nonatomic, assign) CGFloat iconX;
/**
 *  存放用户头像的数组
 */
@property (nonatomic, strong) NSMutableArray *iconViews;
/**
 *  记录调用的次数
 */
@property (nonatomic, assign) NSInteger index;
/**
 *  记录删除按钮
 */
@property (nonatomic, strong) LCUIButton *deleteBtn;
/**
 *  评论列表
 */
@property (nonatomic, strong) NSMutableArray *commentList;

@end

@implementation LKTagCommentsViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

static NSString * __LKUserAddress = nil;

-(instancetype) initWithTag:(LKTag *)tag
{
    self = [super init];
    if (self) {
        self.tagValue = tag;
        self.datasource = [self.tagValue.comments mutableCopy];
        self.locationManager = [LKLocationManager new];
        [self.locationManager requestCurrentLocationWithBlock:^(CLLocation *location, AMapReGeocode *regeocode, NSError *error) {
    
            if (!error) {
                __LKUserAddress = regeocode.addressComponent.city.length ? regeocode.addressComponent.city : regeocode.addressComponent.province;
            }
            
        }];
        
        if (!self.tagValue.user) {
            [self update];
        }
    }
    
    return self;
}

- (void)buildNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    self.title = LC_LO(@"评论详情");
}

- (void)handleNavigationBarButton:(LCUINavigationBarButtonType)type {
    if (type == LCUINavigationBarButtonTypeLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)buildInputView {
    // 添加输入框
    self.inputView = LKInputView.view;
    self.inputView.viewFrameY = self.view.viewFrameHeight - self.inputView.viewFrameHeight - 64;
    self.inputView.dismissButton.title = LC_LO(@"发布");
    self.inputView.textField.placeholder = LC_LO(@"发表评论（最多300个字）");
    self.view.ADD(self.inputView);
    
    @weakly(self);
    self.inputView.sendAction = ^(NSString * string){
        
        @normally(self);
        
        if (string.trim.length == 0) {
            
            [self showTopMessageErrorHud:LC_LO(@"评论不能为空")];
            return;
        }
        
        if (string.length > 300) {
            
            [self showTopMessageErrorHud:LC_LO(@"评论长度不能大于300位")];
            return;
        }
        
        [self sendNewComment:string];
    };
    
    
    self.inputView.willDismiss = ^(id value){
        
        @normally(self);
        
        self.replyUser = nil;
        self.inputView.textField.placeholder = LC_LO(@"发表评论（最多300个字）");
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.tableView.viewFrameHeight = self.blur.viewFrameHeight - 44;
            
        }];
    };
    
    self.inputView.didShow = ^(id value){
        
        @normally(self);
        
        self.canFirstResponder = @(NO);
        
        [UIView animateWithDuration:0.25 animations:^{
            self.tableView.viewFrameHeight = LC_DEVICE_HEIGHT + 20 - self.inputView.viewFrameHeight - [LCUIKeyBoard.singleton height] - 44;
        }];
        
                [self.tableView scrollToBottomAnimated:YES];
        
        [self performSelector:@selector(setCanFirstResponder:) withObject:@(YES) afterDelay:0.5];
    };
}

- (void)buildUI {
    [self buildNavigationBar];
    
    self.view.backgroundColor = LC_RGB(245, 245, 245);
    
    // 除去导航栏的view
    self.blur = LCUIBlurView.view;
    self.blur.viewFrameY = 0;
    self.blur.viewFrameWidth = self.view.viewFrameWidth;
    self.blur.viewFrameHeight = self.view.viewFrameHeight - 20 - 44;
    self.blur.tintColor = LC_RGB(238, 238, 238);
    self.view.ADD(self.blur);
    
    // 在blur中添加tableView
    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = self.blur.bounds;
    self.tableView.viewFrameHeight -= 64;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.tableView.backgroundColor = LC_RGB(238, 238, 238);
    self.blur.ADD(self.tableView);
    
    @weakly(self);
    
    // 下拉刷新
    self.pullLoader = [[LCUIPullLoader alloc] initWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeader];
    
    [self.pullLoader setBeginRefresh:^(LCUIPullLoaderDiretion diretion) {
        @normally(self);
        [self loadData:diretion];
    }];
    
    [self buildInputView];

    [self getTagUsers];
    [self loadData:LCUIPullLoaderDiretionTop];
    
    // 获取评论列表
    [self getCommentList];
}

- (void)update {
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@", self.tagValue.id]].AUTO_SESSION().GET_METHOD();
    
    //[interface addParameter:@"asc" key:@"order"];
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            LKTag * tag = [LKTag objectFromDictionary:result.json[@"data"]];
            
            self.tagValue = tag;
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

/**
 *  发送新评论
 *
 *  @param comment 评论内容
 */
-(void) sendNewComment:(NSString *)comment {
    LKComment * commentObject = [[LKComment alloc] init];
    commentObject.user = LKLocalUser.singleton.user;
    commentObject.replyUser = self.replyUser;
    commentObject.content = comment;
    commentObject.timestamp = @([[NSDate date] timeIntervalSince1970]);
    commentObject.place = __LKUserAddress;
    
    self.tagValue.totalComments = @(self.tagValue.totalComments.integerValue + 1);
    [self.tagValue.comments addObject:commentObject];
    [self.datasource addObject:commentObject];
    
    [self.tableView reloadData];
    [self.tableView scrollToBottomAnimated:NO];
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@/comment", self.tagValue.id]].AUTO_SESSION().POST_METHOD();
    
    if (__LKUserAddress) {
        
        [interface addParameter:__LKUserAddress key:@"place"];
    }
    
    if (self.replyUser) {
        [interface addParameter:self.replyUser.id key:@"reply_id"];
    }
    
    [interface addParameter:comment key:@"content"];
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        if (result.state == LKHttpRequestStateFinished) {
            
            // 重新获取评论列表
            [self getCommentList];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
        };
        
    }];
    
    [self.inputView resignFirstResponder];
    self.inputView.textField.text = @"";
    self.replyUser = nil;
    self.inputView.textField.placeholder = LC_LO(@"发表评论（最多300个字）");
}

/**
 *  输入框成为第一响应者
 */
-(void) inputBecomeFirstResponder
{
    self.inputView.textField.placeholder = LC_LO(@"发表评论（最多300个字）");
    [self.inputView becomeFirstResponder];
}

/**
 *  回复用户的评论
 *
 *  @param user 用户信息
 */
-(void) replyUserAction:(LKUser *)user
{
    self.replyUser = user;
    
    self.inputView.textField.placeholder = [NSString stringWithFormat:@"回复：%@" ,user.name];
    // 增加@用户的功能
    self.inputView.textField.text = [NSString stringWithFormat:@"@%@:", user.name];
    [self.inputView becomeFirstResponder];
}

/**
 *  加载数据
 *
 *  @param diretion 拖动的方向
 */
-(void) loadData:(LCUIPullLoaderDiretion)diretion
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@/comment?order=asc", self.tagValue.id]].AUTO_SESSION().GET_METHOD();
    
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray * data = result.json[@"data"][@"comments"];
            
            NSMutableArray * resultArray = [NSMutableArray array];
            
            for (NSDictionary * value in data) {
                
                [resultArray addObject:[LKComment objectFromDictionary:value]];
            }
            
            if (diretion == LCUIPullLoaderDiretionTop) {
                self.datasource = resultArray;
            }
            
            [self.pullLoader endRefresh];
            [self.tableView reloadData];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self.pullLoader endRefresh];
        };
        
    }];
}

#pragma mark - 

LC_HANDLE_UI_SIGNAL(PushUserCenter, signal)
{
    [self.inputView resignFirstResponder];
}

-(void) showInViewController:(UIViewController *)viewController {
}

/**
 *  点击header或后退按钮后执行,移除当前控制器
 */
-(void) hide {
}

#pragma mark -

-(NSInteger) numberOfSectionsInTableView:(LCUITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.datasource.count;
    }
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        CGFloat leftPadding = 24;
        CGFloat topPadding = 12;

        LCUITableViewCell *cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Header" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.backgroundColor = [UIColor whiteColor];
            configurationCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            LCUIImageView *headImageView = LCUIImageView.view;
            headImageView.viewFrameX = leftPadding;
            headImageView.viewFrameY = topPadding;
            headImageView.viewFrameWidth = 35;
            headImageView.viewFrameHeight = 35;
            headImageView.cornerRadius = headImageView.viewMidWidth;
            headImageView.backgroundColor = LKColor.backgroundColor;
            headImageView.tag = 1001;
            configurationCell.ADD(headImageView);
            
            
            LCUILabel *nameLable = LCUILabel.view;
            nameLable.font = LK_FONT(12);
            nameLable.textColor = [UIColor blackColor];
            nameLable.viewFrameX = leftPadding;
            nameLable.viewFrameY = headImageView.viewBottomY + topPadding;
            nameLable.viewFrameHeight = nameLable.font.lineHeight;
            nameLable.viewFrameWidth = 200;
            nameLable.tag = 1004;
            configurationCell.ADD(nameLable);
            
            
            LCUILabel *timeLabel = LCUILabel.view;
            timeLabel.font = LK_FONT(12);
            timeLabel.viewFrameWidth = 100;
            timeLabel.viewFrameHeight = timeLabel.font.lineHeight;
            timeLabel.viewFrameX = LC_DEVICE_WIDTH - timeLabel.viewFrameWidth - 10;
            timeLabel.viewFrameY = nameLable.viewFrameY;
            timeLabel.textAlignment = UITextAlignmentRight;
            timeLabel.textColor = LC_RGB(171, 164, 157);
            timeLabel.tag = 1003;
//            timeLabel.hidden = YES;
            configurationCell.ADD(timeLabel);
            
            
            // 删除按钮
            LCUIButton *deleteBtn = LCUIButton.view;
            [deleteBtn setTitleFont:LK_FONT(12)];
            [deleteBtn setTitle:LC_LO(@"删除") forState:UIControlStateNormal];
            [deleteBtn sizeToFit];
            deleteBtn.viewFrameX = LC_DEVICE_WIDTH - deleteBtn.viewFrameWidth - 6;
            deleteBtn.viewCenterY = headImageView.viewCenterY;
            deleteBtn.titleLabel.textAlignment = UITextAlignmentRight;
            [deleteBtn setTitleColor:LC_RGB(180, 180, 180) forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            // 默认隐藏
            deleteBtn.hidden = YES;
            self.deleteBtn = deleteBtn;
            configurationCell.ADD(deleteBtn);
    
            
            UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH;
            configurationCell.ADD(line);
            
            
            UIImageView *line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line1.viewFrameY = 74 + 8 - 1;
            line1.viewFrameWidth = LC_DEVICE_WIDTH;
            configurationCell.ADD(line1);
        }];
        
        LCUIImageView *head = cell.FIND(1001);
        LKTagItemView *item = cell.FIND(1002);
        LCUILabel *time = cell.FIND(1003);
        LCUILabel *name = cell.FIND(1004);
        
        if (item) {
            
            [item removeFromSuperview];
            item = nil;
        }
        
        if (self.tagValue.tag.length) {
        
            item = LKTagItemView.view;
            item.tag = 1002;
            cell.ADD(item);
        }
        
        LKUser *tagUser = self.tagValue.user;
//        head.url = self.tagValue.user.avatar;
        [head sd_setImageWithURL:[NSURL URLWithString:tagUser.avatar] placeholderImage:nil];
        item.tagValue = self.tagValue;
        item.viewFrameX = head.viewRightX + 19;
//        item.viewFrameY = 53 / 2 - item.viewMidHeight;
        item.viewCenterY = head.viewCenterY;
        time.text = [LKTime dateNearByTimestamp:self.tagValue.createTime];
        name.text = [NSString stringWithFormat:@"%@  %@ likes", tagUser.name, tagUser.likes];
        
        // 添加一个scrollView用来显示标签用户
        UIScrollView *tagUserView = UIScrollView.view;
        tagUserView.viewFrameX = item.viewFrameX;
        tagUserView.viewFrameY = name.viewBottomY + 16;
        tagUserView.viewFrameWidth = LC_DEVICE_WIDTH - tagUserView.viewFrameX - 20;
        self.tagUserView = tagUserView;
        cell.ADD(tagUserView);
        
        // 去掉水平滚动条
        tagUserView.showsHorizontalScrollIndicator = NO;
    
        // 添加子控件
        [self addChildViews:tagUserView];
        
        if (self.tagUserView.viewFrameHeight) {
            
            UIImageView *line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line2.viewFrameY = 74 + 16 + self.tagUserView.viewFrameHeight + 8 - 1;
            line2.viewFrameWidth = LC_DEVICE_WIDTH;
            cell.ADD(line2);
        }
        
        return cell;
        
    } else {
        
        LKTagCommentCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Comments" andClass:[LKTagCommentCell class]];
        
        cell.comment = self.datasource[indexPath.row];
        cell.backgroundColor = LC_RGB(238, 238, 238);
        
        return cell;
    }
}

- (void)getTagUsers {
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@/likes",self.tagValue.id]].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSArray *usersDic = result.json[@"data"][@"likes"];
            
            NSMutableArray *users = [NSMutableArray array];
            
            for (NSDictionary *dict in usersDic) {
                
                [users addObject:[LKUser objectFromDictionary:dict[@"user"]]];
            }
            
            // 添加子控件
            self.tagUsers = users;
            
            // 判断是否是用户或者标签所有者
            BOOL canDelete = [self userOrTagOwner];
            
            self.deleteBtn.hidden = !canDelete;
            
        }
        else if (result.state == LKHttpRequestStateFailed){
            
        }
        
    }];
}

/**
 *  判断是否是用户或者标签所有者
 */
- (BOOL)userOrTagOwner {
    
    // 获取标签所有者
    LKUser *owner = [self.tagUsers lastObject];
    // 获取发布者
    LKUser *publisher = self.publisher.user;
    
    LKUser *user = LKLocalUser.singleton.user;
    
    // 和当前用户的id进行比较
    if (owner.id.integerValue == user.id.integerValue || publisher.id.integerValue == user.id.integerValue) {
    
        return YES;
    }
    
    return NO;
}

#pragma mark - ***** 添加子控件 *****
- (void)addChildViews:(UIScrollView *)tagUserView {
    
    // 头像间距
    CGFloat margin = 8;
    
    LCUIImageView *lastIcon = nil;
    for (int i = 0; i < self.tagUsers.count; i++) {
        
        NSInteger column = tagUserView.viewFrameWidth / (iconWH + margin);
        LKUser *user = self.tagUsers[i];
        
        LCUIImageView *iconView = LCUIImageView.view;
        iconView.viewFrameX = (iconWH + margin) * (i % column);
        iconView.viewFrameY = lastIcon.viewFrameY;
        iconView.viewFrameWidth = iconWH;
        iconView.viewFrameHeight = iconWH;
        
        if (lastIcon.viewRightX + 2 * margin + iconWH > tagUserView.viewFrameWidth) {
            
            iconView.viewFrameX = 0;
            iconView.viewFrameY = lastIcon.viewBottomY + 8;
        }
        
        
        [self.tagUserView addSubview:iconView];
        [self.iconViews addObject:iconView];
        
        iconView.tag = i;
        
        // 记录下iconX
        self.iconX = iconView.viewFrameX;
        
        [iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", user.avatar]]];
        
        // 裁剪
        iconView.layer.cornerRadius = iconWH * 0.5;
        iconView.layer.masksToBounds = YES;
        
        lastIcon = iconView;
    }
    
    self.tagUserView.viewFrameHeight = lastIcon.viewBottomY;
    
    for (LCUIImageView *iconView in self.iconViews) {
    
        // 启用和用户的交互
        iconView.userInteractionEnabled = YES;
        [iconView addTapGestureRecognizer:self selector:@selector(iconViewClick:)];

        // 设置scrollView的contentSize
        self.tagUserView.scrollEnabled = YES;
    }
}

/**
 *  点击头像执行
 */
- (void)iconViewClick:(UITapGestureRecognizer *)tapGes {
    
    LKUser *user = self.tagUsers[tapGes.view.tag];
    self.SEND(@"PushUserCenter").object = user;
}

-(void) reloadDataAndUpdate
{
    [self.tableView reloadData];
}

- (void)deleteBtnClick:(LCUIButton *)deleteBtn {

    // 注销第一响应者
    [self.inputView resignFirstResponder];
    // 弹窗提示
    [LCUIAlertView showWithTitle:LC_LO(@"提醒") message:LC_LO(@"删除该标签后，你的like数也会相应减少，确认删除吗？") cancelTitle:LC_LO(@"确定") otherTitle:LC_LO(@"取消") didTouchedBlock:^(NSInteger integerValue) {

        switch (integerValue) {
            case 0:     // 确定
            {
                // 发送请求,删除标签
                [self deleteTagWithDeleteBtn:deleteBtn];
                
                // 删除标签,使用代理
                if ([self.delegate respondsToSelector:@selector(tagCommentsViewController:didClickedDeleteBtn:)]) {
                    
                    [self.delegate tagCommentsViewController:self didClickedDeleteBtn:deleteBtn];
                }
                
                // 回到上一页
                [self hide];
                
                break;
            }
                
            case 1:
                break;
                
            default:
                break;
        }
    }];
}

- (void)deleteTagWithDeleteBtn:(LCUIButton *)deleteBtn {
    
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@", self.tagValue.id]].AUTO_SESSION().DELETE_METHOD();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            

        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

#pragma mark - ***** tableView的代理方法 *****
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        
        // 待修改
        return 74 + 16 + self.tagUserView.viewFrameHeight + 8;
    } else {
        
        // 修改了cell的行高,解决左滑显示删除按钮错位的问题
        return [LKTagCommentCell height:self.datasource[indexPath.row]] - 4;
    }

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        self.SEND(@"PushUserCenter").object = self.tagValue.user;
    }
    else{
     
        LKComment * comment = self.datasource[indexPath.row];
        
        if (LKLocalUser.singleton.user.id.integerValue != comment.user.id.integerValue) {
            
            [self replyUserAction:comment.user];
        }
        else{
            [self inputBecomeFirstResponder];
        }
    }
}

/**
 *  设置可编辑的行
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1 ? YES : NO;
}

/**
 *  设置编辑样式
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 重新获取评论列表
        [self getCommentList];
        
        // 判断是否是图片发布者或者评论发布者
        NSInteger index = indexPath.row;
        BOOL canDelete = [self publisherOrCommentatorWithIndex:index];
        
        if (canDelete) {
            
            // 删除评论
            // 发送请求,删除数据
            [self deletCommentWithIndex:index];
            
        } else {
            
            self.tableView.editing = NO;
        }
    }
}

- (BOOL)publisherOrCommentatorWithIndex:(NSInteger)index {
    
    // 获取发布者
    LKUser *publisher = self.publisher.user;
    
    // 获取评论者
    LKComment *commmet = self.commentList[self.commentList.count - index - 1];
    LKUser *commentator = commmet.user;
    
    // 获取当前用户
    LKUser *user = LKLocalUser.singleton.user;
    
    if (publisher.id.integerValue == user.id.integerValue || commentator.id.integerValue == user.id.integerValue) {
        
        return YES;
    }
    
    return NO;
}

/**
 *  获取评论列表
 */
- (void)getCommentList {
    
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@/comments", self.tagValue.id]].AUTO_SESSION().GET_METHOD();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            
            NSArray *commentList = result.json[@"data"][@"comments"];
            
            NSMutableArray *arrayM = [NSMutableArray array];
            
            for (NSDictionary *dict in commentList) {
                
                [arrayM addObject:[LKComment objectFromDictionary:dict]];
            }
            
            self.commentList = arrayM;
            
            [self.pullLoader endRefresh];
            [self.tableView reloadData];
            
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

/**
 *  删除评论
 */
- (void)deletCommentWithIndex:(NSInteger)index {
    
    NSInteger commentCount = self.commentList.count;
    LKComment *commment = self.commentList[commentCount - index - 1];
    
    LKHttpRequestInterface *interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"comment/%@", commment.id]].AUTO_SESSION().DELETE_METHOD();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {

            // 重新获取评论列表
            [self getCommentList];

            // 刷新
            [self.pullLoader startRefresh];
            
        } else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

#pragma mark - ***** scrollView代理方法 *****
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.canFirstResponder.boolValue) {
        [self.inputView resignFirstResponder];
    }
}

- (void)setPublisher:(LKPost *)publisher {
    _publisher = publisher;

}

#pragma mark - ***** 懒加载 *****
- (NSMutableArray *)tagUsers {
    
    if (_tagUsers == nil) {
        _tagUsers = [NSMutableArray array];
    }
    return _tagUsers;
}

- (NSMutableArray *)iconViews {
    
    if (_iconViews == nil) {
        _iconViews = [NSMutableArray array];
    }
    return _iconViews;
}

- (NSMutableArray *)commentList {
    
    if (_commentList == nil) {
        _commentList = [NSMutableArray array];
    }
    return _commentList;
}

@end
