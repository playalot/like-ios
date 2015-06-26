//
//  LKLinkAccountsViewController.m
//  LIKE
//
//  Created by Licheng Guo ( http://nsobjet.me ) on 15/6/17.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLinkAccountsViewController.h"
#import "LKFacebookShare.h"
#import "LKSinaShare.h"
#import "LKWeChatShare.h"
#import "LKRebindPhoneViewController.h"
#import "LKTimestampEncryption.h"


typedef NS_ENUM(NSInteger, LKLinkAccountState)
{
    LKLinkAccountStateUnknown,
    LKLinkAccountStateBind,
    LKLinkAccountStateUnbind,
};

@interface __LKLinkAccount : NSObject

LC_PROPERTY(strong) UIImage * icon;
LC_PROPERTY(copy) NSString * title;
LC_PROPERTY(copy) NSString * key;
LC_PROPERTY(assign) LKLinkAccountState state;
LC_PROPERTY(copy) NSString * identifier;

LC_PROPERTY(copy) NSString * token;

@end

@implementation __LKLinkAccount

@end

#pragma mark -

@interface LKLinkAccountsViewController ()

LC_PROPERTY(strong) NSMutableArray * datasource;

@end

@implementation LKLinkAccountsViewController

-(void) dealloc
{
    [self cancelAllRequests];
}

-(instancetype) init
{
    if (self = [super init]) {
        
        self.datasource = [NSMutableArray array];
        
        NSArray * icon = @[@"FacebookIcon.png", @"WeChatFriendIcon.png", @"SinaIcon.png", @"MobileIcon.png"];
        NSArray * titles = @[LC_LO(@"Facebook"), LC_LO(@"微信"), LC_LO(@"微博"), LC_LO(@"手机号")];
        NSArray * identifier = @[@"facebook", @"wechat", @"weibo", @"mobile"];

        
        for (NSInteger i = 0; i < icon.count; i++) {
            
            __LKLinkAccount * linkAccount = __LKLinkAccount.new;
            linkAccount.icon = [UIImage imageNamed:icon[i] useCache:YES];
            linkAccount.title = titles[i];
            linkAccount.identifier = identifier[i];
            
            [self.datasource addObject:linkAccount];
        }
    }
    
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarHidden:NO animated:animated];
    
    [self loadData];
}

-(void) buildUI
{
    self.title = LC_LO(@"账号绑定");
    
    [self setNavigationBarButton:LCUINavigationBarButtonTypeLeft image:[UIImage imageNamed:@"NavigationBarBack.png" useCache:YES] selectImage:nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:LKColor.color andSize:CGSizeMake(LC_DEVICE_WIDTH, 64)] forBarMetrics:UIBarMetricsDefault];
    
    
    LCUILabel * label = LCUILabel.view;
    label.viewFrameY = 300;
    label.viewFrameWidth = LC_DEVICE_WIDTH - 40;
    label.numberOfLines = 0;
    label.font = LK_FONT(13);
    label.textColor = LC_RGB(84, 79, 73);
    label.text = LC_LO(@"绑定账号后可以使用它们登录like，如遇问题请发送邮件至support@likeorz.com");
    label.FIT();
    label.viewCenterX = self.view.viewMidWidth;
    self.view.ADD(label);
}

-(void) loadData
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"account/list"].AUTO_SESSION();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            NSDictionary * datasource = result.json[@"data"][@"linked_accounts"];
            
            for (__LKLinkAccount * account in self.datasource) {
                
                NSString * key = datasource[account.identifier];

                if (key) {
                    
                    account.key = key;
                    account.state = LKLinkAccountStateBind;
                }
                else{
                    
                    account.state = LKLinkAccountStateUnbind;
                }
            }
            
            [self reloadData];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
    }];
    
}

-(void) handleNavigationBarButton:(LCUINavigationBarButtonType)type
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(LCUITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LCUITableViewCell * cell = [tableView autoCreateDequeueReusableCellWithIdentifier:@"Cell" andClass:[LCUITableViewCell class] configurationCell:^(LCUITableViewCell * configurationCell) {
        
        configurationCell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        subLabel.viewFrameX = label.viewFrameX;
        subLabel.viewFrameY = 40;
        subLabel.viewFrameWidth = 200;
        subLabel.viewFrameHeight = 12;
        subLabel.font = LK_FONT(10);
        subLabel.textColor = LC_RGB(180, 180, 180);
        subLabel.tag = 1003;
        subLabel.numberOfLines = 0;
        configurationCell.ADD(subLabel);
        
        
        LCUIButton * actionButton = LCUIButton.view;
        actionButton.viewFrameWidth = 55;
        actionButton.viewFrameHeight = 23;
        actionButton.viewFrameX = LC_DEVICE_WIDTH - 55 - 40;
        actionButton.viewFrameY = 200 / 3 / 2 - actionButton.viewMidHeight;
        actionButton.cornerRadius = actionButton.viewMidHeight;
        actionButton.titleFont = LK_FONT(11);
        actionButton.tag = 1004;
        actionButton.userInteractionEnabled = NO;
        configurationCell.ADD(actionButton);
        
        
        UIView * line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkLine.png" useCache:YES]];
        line.viewFrameWidth = LC_DEVICE_WIDTH - 40;
        line.viewFrameX = 20;
        line.viewFrameY = 200 / 3 - line.viewFrameHeight;
        configurationCell.ADD(line);
        
    }];
    
    LCUIButton * icon = cell.FIND(1001);
    LCUILabel * title = cell.FIND(1002);
    LCUILabel * subTitle = cell.FIND(1003);
    LCUIButton * action = cell.FIND(1004);
    
    __LKLinkAccount * account = self.datasource[indexPath.row];
    
    icon.image = account.icon;
    title.text = account.title;
    
    if (indexPath.row == 3) {
        
        subTitle.text = account.key ? [NSString stringWithFormat:@"%@%@", LC_LO(@"已绑定"), account.key] : @"";
    }
    else{
        
        subTitle.text = @"";
    }
    
    switch (account.state) {
            
        case LKLinkAccountStateUnknown:
        {
            LC_FAST_ANIMATIONS(0.25, ^{
                
                action.alpha = 0;
            });
        }
            break;
        case LKLinkAccountStateBind:
        {
            LC_FAST_ANIMATIONS(0.25, ^{
                
                action.alpha = 1;
            });
            
            action.backgroundColor = LC_RGB(245, 240, 236);
            action.titleColor = LC_RGB(84, 79, 73);

            if (indexPath.row == 3) {
                
                action.title = LC_LO(@"修改");
            }
            else{
                
                action.title = LC_LO(@"解绑");
            }
        }
            break;
           
        case LKLinkAccountStateUnbind:
        {
            LC_FAST_ANIMATIONS(0.25, ^{
                
                action.alpha = 1;
            });
            
            action.backgroundColor = LKColor.color;
            action.title = LC_LO(@"绑定");
            action.titleColor = [UIColor whiteColor];
        }
            break;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200 / 3;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    LCUIButton * button = cell.FIND(1004);
    
    if (button.title.length == 0) {
        
        return;
    }
    else if (indexPath.row == 3){
        
        [self.navigationController pushViewController:[LKRebindPhoneViewController viewController] animated:YES];
    }
    else if ([button.title isEqualToString:LC_LO(@"解绑")]) {
        
        [self unbindWithLinkAccount:self.datasource[indexPath.row]];
    }
    else if ([button.title isEqualToString:LC_LO(@"绑定")]){
        
        [self bindWithLinkAccount:self.datasource[indexPath.row]];
    }
    else if ([button.title isEqualToString:LC_LO(@"修改")]){
        
        [self.navigationController pushViewController:[LKRebindPhoneViewController viewController] animated:YES];
    }
}

-(void) bindWithLinkAccount:(__LKLinkAccount *)linkAccount
{
    if ([linkAccount.identifier isEqualToString:@"mobile"]) {
        
        // TODO:
    }
    else{
        
        if ([linkAccount.identifier isEqualToString:@"weibo"]) {
            
            [LKSinaShare.singleton login:^(NSString *uid, NSString *accessToken, NSString *error) {
               
                if (!error) {
                    
                    linkAccount.key = uid;
                    linkAccount.token = accessToken;
                    
                    [self requestBindWithLinkAccount:linkAccount];
                }
                else{
                    
                    [self showTopMessageErrorHud:error];
                }

            }];
        }
        else if ([linkAccount.identifier isEqualToString:@"wechat"]){
            
            [LKWeChatShare.singleton login:^(NSString *uid, NSString *accessToken, NSString *error) {
                
                if (!error) {
                    
                    linkAccount.key = uid;
                    linkAccount.token = accessToken;
                    
                    [self requestBindWithLinkAccount:linkAccount];
                }
                else{
                    
                    [self showTopMessageErrorHud:error];
                }
            }];
        }
        else if ([linkAccount.identifier isEqualToString:@"facebook"]){
            
            [LKFacebookShare.singleton login:^(NSString *uid, NSString *accessToken, NSString * nick, NSString *error) {
                
                if (!error) {
                    
                    linkAccount.key = uid;
                    linkAccount.token = accessToken;
                    
                    [self requestBindWithLinkAccount:linkAccount];
                }
                else{
                    
                    [self showTopMessageErrorHud:error];
                }
            }];
        }
    }
}

-(void) requestBindWithLinkAccount:(__LKLinkAccount *)linkAccount
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"account/link/%@", linkAccount.identifier]].AUTO_SESSION().POST_METHOD();
    
    [interface addParameter:linkAccount.key key:@"uid"];
    [interface addParameter:linkAccount.token key:@"access_token"];
    [interface addParameter:[LKTimestampEncryption encryption:[[NSDate date] timeIntervalSince1970]] key:@"token"];

    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
       
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            linkAccount.state = LKLinkAccountStateBind;
            [self reloadData];
        }
        else if(result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
        
    }];
}

-(void) unbindWithLinkAccount:(__LKLinkAccount *)linkAccount
{
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:[NSString stringWithFormat:@"account/link/%@", linkAccount.identifier]].AUTO_SESSION().DELETE_METHOD();
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult *result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            linkAccount.state = LKLinkAccountStateUnbind;
            [self reloadData];
        }
        else if(result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
        }
        
    }];
}

@end
