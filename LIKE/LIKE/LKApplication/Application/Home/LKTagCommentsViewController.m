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

@interface LKTagCommentsViewController () <UITableViewDataSource,UITableViewDelegate>

LC_PROPERTY(strong) LKTag * tagValue;

LC_PROPERTY(strong) LCUILabel * header;
LC_PROPERTY(strong) LCUIBlurView * blur;
LC_PROPERTY(strong) LCUITableView * tableView;
LC_PROPERTY(strong) LCUIPullLoader * pullLoader;
LC_PROPERTY(strong) LKInputView * inputView;

LC_PROPERTY(strong) LKUser * replyUser;

LC_PROPERTY(strong) NSMutableArray * datasource;

@end

@implementation LKTagCommentsViewController


-(void) dealloc
{
    [self cancelAllRequests];
}


-(instancetype) initWithTag:(LKTag *)tag
{
    if (self = [super initWithFrame:CGRectMake(0, 0, LC_DEVICE_WIDTH, LC_DEVICE_HEIGHT + 20)]) {
        
        self.tagValue = tag;
        self.datasource = [self.tagValue.comments mutableCopy];
        
        [self buildUI];
    }
    
    return self;
}

-(void) buildUI
{
    self.header = LCUILabel.view;
    self.header.frame = CGRectMake(0, 0, self.viewFrameWidth, 44);
    self.header.textAlignment = UITextAlignmentCenter;
    self.header.font = LK_FONT_B(16);
    self.header.textColor = [UIColor whiteColor];
    self.header.text = @"评论详情";
    [self.header addTapGestureRecognizer:self selector:@selector(hide)];
    self.ADD(self.header);
    
    
    LCUIButton * backButton = LCUIButton.view;
    backButton.viewFrameWidth = 54;
    backButton.viewFrameHeight = 55 / 3 + 28;
    backButton.viewFrameY = 0;
    backButton.buttonImage = [UIImage imageNamed:@"NavigationBarDismiss.png" useCache:YES];
    backButton.showsTouchWhenHighlighted = YES;
    [backButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 1002;
    [self addSubview:backButton];
    
    
    self.blur = LCUIBlurView.view;
    self.blur.viewFrameY = 44;
    self.blur.viewFrameWidth = self.viewFrameWidth;
    self.blur.viewFrameHeight = self.viewFrameHeight - 44;
    self.blur.tintColor = [UIColor whiteColor];
    self.ADD(self.blur);
    
    
    self.tableView = [[LCUITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = self.blur.bounds;
    self.tableView.viewFrameHeight -= 44;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = YES;
    self.blur.ADD(self.tableView);
    
    
    
    @weakly(self);
    
    
    self.pullLoader = [[LCUIPullLoader alloc] initWithScrollView:self.tableView pullStyle:LCUIPullLoaderStyleHeader];
    
    [self.pullLoader setBeginRefresh:^(LCUIPullLoaderDiretion diretion) {
        
        @normally(self);
        
        [self loadData:diretion];
        
    }];
    
    
    [self loadData:LCUIPullLoaderDiretionTop];
    
    
    
    self.inputView = LKInputView.view;
    self.inputView.viewFrameY = self.viewFrameHeight - self.inputView.viewFrameHeight;
    self.inputView.dismissButton.title = @"发布";
    self.inputView.textField.placeholder = @"发表评论（最多300个字）";
    self.ADD(self.inputView);
    
    self.inputView.sendAction = ^(NSString * string){
        
        @normally(self);
        
        if (string.trim.length == 0) {
            
            [self showTopMessageErrorHud:@"评论不能为空"];
            return;
        }
        
        if (string.length > 300) {
            
            [self showTopMessageErrorHud:@"评论长度不能大于300位"];
            return;
        }
        
        [self sendNewComment:string];
    };

    
    self.inputView.willDismiss = ^(id value){
      
        @normally(self);
        
        self.replyUser = nil;
        self.inputView.textField.placeholder = @"发表评论（最多300个字）";
    };
}

-(void) sendNewComment:(NSString *)comment
{
    LKComment * commentObject = [[LKComment alloc] init];
    commentObject.user = LKLocalUser.singleton.user;
    commentObject.replyUser = self.replyUser;
    commentObject.content = comment;
    commentObject.timestamp = @([[NSDate date] timeIntervalSince1970]);
    
    self.tagValue.totalComments = @(self.tagValue.totalComments.integerValue + 1);
    [self.tagValue.comments insertObject:commentObject atIndex:0];
    [self.datasource insertObject:commentObject atIndex:0];
    
    [self.tableView reloadData];
    
    
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@/comment", self.tagValue.id]].AUTO_SESSION().POST_METHOD();
    
    if (self.replyUser) {
        [interface addParameter:self.replyUser.id key:@"reply_id"];
    }
    
    [interface addParameter:comment key:@"content"];
    
    interface.jsonFormat = YES;
    interface.customAPIURL = LK_API2;
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        if (result.state == LKHttpRequestStateFinished) {
            
        }
        else if (result.state == LKHttpRequestStateFailed){
            
        };
        
    }];
    
    
    
    [self.inputView resignFirstResponder];
    self.inputView.textField.text = @"";
    self.replyUser = nil;
    self.inputView.textField.placeholder = @"发表评论（最多300个字）";

}

-(void) inputBecomeFirstResponder
{
    self.inputView.textField.placeholder = @"发表评论（最多300个字）";
    [self.inputView becomeFirstResponder];
}

-(void) replyUserAction:(LKUser *)user
{
    self.replyUser = user;
    
    self.inputView.textField.placeholder = [NSString stringWithFormat:@"回复：%@" ,user.name];
    [self.inputView becomeFirstResponder];
}

-(void) loadData:(LCUIPullLoaderDiretion)diretion
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"mark/%@/comment", self.tagValue.id]].AUTO_SESSION().GET_METHOD();
    interface.customAPIURL = LK_API2;
    
    
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
//            else{
//                [self.datasource addObjectsFromArray:resultArray];
//            }
            
            [self.pullLoader endRefresh];
            [self.tableView reloadData];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self.pullLoader endRefresh];
        };
        
    }];
}

#pragma mark - 

-(void) showInViewController:(UIViewController *)viewController
{
    UIView * view = self.FIND(1002);
    view.alpha = 0;
    
    self.header.alpha = 0;
    
    self.blur.viewFrameY = self.viewFrameHeight;
    
    [viewController.view addSubview:self];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        view.alpha = 1;
        
        self.header.alpha = 1;
        self.blur.viewFrameY = 44;
        
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) hide
{
    if (self.willHide) {
        self.willHide();
    }
    
    [self.inputView resignFirstResponder];
    
    UIView * view = self.FIND(1002);
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        view.alpha = 0;
        
        self.header.alpha = 0;
        self.blur.viewFrameY = self.viewFrameHeight;
        self.inputView.viewFrameY = self.viewFrameHeight;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

#pragma mark -

-(NSInteger) numberOfSectionsInTableView:(LCUITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
    }
    else{
        
        return self.datasource.count;
    }
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        LCUITableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Header" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
            
            configurationCell.backgroundColor = [UIColor whiteColor];
            configurationCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGFloat padding = 10;
            
            LCUIImageView * headImageView = LCUIImageView.view;
            headImageView.viewFrameX = padding;
            headImageView.viewFrameY = padding;
            headImageView.viewFrameWidth = 33;
            headImageView.viewFrameHeight = 33;
            headImageView.cornerRadius = headImageView.viewMidWidth;
            headImageView.backgroundColor = [UIColor whiteColor];
            headImageView.url = self.tagValue.user.avatar;
            configurationCell.ADD(headImageView);

            
            LKTagItem * tagItem = LKTagItem.view;
            tagItem.tagValue = self.tagValue;
            tagItem.viewFrameX = headImageView.viewRightX + padding;
            tagItem.viewFrameY = 53 / 2 - tagItem.viewMidHeight;
            configurationCell.ADD(tagItem);
            
            
            LCUILabel * timeLabel = LCUILabel.view;
            timeLabel.viewFrameWidth = 100;
            timeLabel.viewFrameX = LC_DEVICE_WIDTH - timeLabel.viewFrameWidth - 10;
            timeLabel.viewFrameHeight = 53;
            timeLabel.font = LK_FONT(13);
            timeLabel.textAlignment = UITextAlignmentRight;
            timeLabel.textColor = LC_RGB(171, 164, 157);
            timeLabel.text = [LKTime dateNearByTimestamp:self.tagValue.createTime];
            configurationCell.ADD(timeLabel);
            
            
            
            UIImageView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line.viewFrameWidth = LC_DEVICE_WIDTH;
            configurationCell.ADD(line);
            
            
            UIImageView * line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
            line1.viewFrameY = 53 - line1.viewFrameHeight;
            line1.viewFrameWidth = LC_DEVICE_WIDTH;
            configurationCell.ADD(line1);
        }];
        
        return cell;
    }
    else{
        
        LKTagCommentCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Comments" andClass:[LKTagCommentCell class]];
        
        cell.comment = self.datasource[indexPath.row];
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        
        return 53;
    }
    else{
        
        return [LKTagCommentCell height:self.datasource[indexPath.row]];
    }

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LKComment * comment = self.datasource[indexPath.row];
    
    if (LKLocalUser.singleton.user.id.integerValue != comment.user.id.integerValue) {
        
        [self replyUserAction:comment.user];
    }
    else{
        
        [self inputBecomeFirstResponder];
    }
    
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.inputView resignFirstResponder];
}

@end
