//
//  LKLoginViewController.m
//  LIKE
//
//  Created by Leer on 15/4/10.
//  Copyright (c) 2015年 Beijing Like Technology Co.Ltd . ( http://www.likeorz.com ). All rights reserved.
//

#import "LKLoginViewController.h"
#import "LKUserInfoModel.h"
#import "LKWelcome.h"

@interface LKLoginViewController ()

LC_PROPERTY(assign) NSInteger timeInterval;

LC_PROPERTY(strong) LCUITextField * phoneField;
LC_PROPERTY(strong) LCUITextField * codeField;
LC_PROPERTY(strong) LCUIButton * codeButton;
LC_PROPERTY(strong) LCUIButton * loginButton;
LC_PROPERTY(strong) LCUIButton * maskView;

LC_PROPERTY(strong) NSString * sesstionToken;
LC_PROPERTY(strong) NSString * refreshToken;
LC_PROPERTY(strong) NSNumber * expiresIn;

LC_PROPERTY_MODEL(LKUserInfoModel, userInfoModel);

LC_PROPERTY(strong) LCUIImageView * backgroundView;

@end

@implementation LKLoginViewController

+(BOOL) needLoginOnViewController:(UIViewController *)viewController
{
    if (LKLocalUser.singleton.isLogin) {
        return NO;
    }
    else{
        
        LKLoginViewController * login = LKLoginViewController.viewController;
        [login view];
        
        login.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [login currentWindowBlur:viewController];
        
        [[LCUIApplication sharedInstance] presentViewController:login animation:YES];
        
        return YES;
    }
}

-(instancetype) init
{
    if (self = [super init]) {
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    return self;
}

-(void) currentWindowBlur:(UIViewController *)viewController
{
    if (!viewController) {
        return;
    }
    
    UIImage * image = [[self snapshotFromParentmostViewController:viewController] imageWithBlurValue:15];

    [self.backgroundView removeFromSuperview];
    
    self.backgroundView = [LCUIImageView viewWithImage:image];
    self.backgroundView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.backgroundView.viewFrameHeight = (LC_DEVICE_HEIGHT + 20);
    self.backgroundView.center = self.view.center;
    [self.view insertSubview:self.backgroundView atIndex:0];
    
    
    UIView * mask = UIView.view.COLOR([[UIColor blackColor] colorWithAlphaComponent:0.35]);
    mask.frame = self.backgroundView.bounds;
    self.backgroundView.ADD(mask);
    
    
    
    self.backgroundView.alpha = 0;
    
    LC_FAST_ANIMATIONS(1, ^{
       
        self.backgroundView.alpha = 1;
        
    });
}


-(void) beginAnimation
{
    LC_FAST_ANIMATIONS(1, ^{
       
        for (UIView * view in self.view.subviews) {
            
            if (view != self.backgroundView) {
                
                view.alpha = 1;
            }
        }
        
    });
    
//    [UIView animateWithDuration:1 delay:5 options:UIViewAnimationOptionCurveLinear animations:^{
//        
//        
//        
//    } completion:^(BOOL finished) {
//        ;
//    }];
}


- (UIImage *)snapshotFromParentmostViewController:(UIViewController *)viewController
{
    UIViewController *presentingViewController = viewController.view.window.rootViewController;
    while (presentingViewController.presentedViewController) presentingViewController = presentingViewController.presentedViewController;

    UIGraphicsBeginImageContextWithOptions(presentingViewController.view.bounds.size, YES, [UIScreen mainScreen].scale);
    [presentingViewController.view drawViewHierarchyInRect:presentingViewController.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    self.userInfoModel = LKUserInfoModel.new.OBSERVER(self);
    
    @weakly(self);
    
    self.userInfoModel.requestFinished = ^(LKHttpRequestResult * result, NSString * error){
    
        @normally(self);
        
        if (error) {
            
            [self showTopMessageErrorHud:error];
        }
        else{
            
            self.maskView.hidden = YES;
            
            NSMutableDictionary * dic =  [self.userInfoModel.rawUserInfo mutableCopy];
            

            [LKLocalUser login:dic];
            LKLocalUser.singleton.sessionToken = self.sesstionToken;
            LKLocalUser.singleton.refreshToken = self.refreshToken;
            LKLocalUser.singleton.expiresIn = [NSString stringWithFormat:@"%@", self.expiresIn];

            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
}

-(void) buildUI
{
    @weakly(self);
    
    self.tableView.didTap = ^(){
        
        @normally(self);
        
        [self.phoneField resignFirstResponder];
        [self.codeField resignFirstResponder];
    };
    
    
    self.backgroundView = [LCUIImageView viewWithImage:[[LKWelcome image] imageWithBlurValue:15]];
    self.backgroundView.viewFrameWidth = LC_DEVICE_WIDTH * 1.5;
    self.backgroundView.viewFrameHeight = (LC_DEVICE_HEIGHT + 20) * 1.5;
    self.backgroundView.center = self.view.center;
    self.view.ADD(self.backgroundView);
    
    
    UIView * mask = UIView.view.COLOR([[UIColor blackColor] colorWithAlphaComponent:0.35]);
    mask.frame = self.backgroundView.bounds;
    self.backgroundView.ADD(mask);
    
    
    LCUIImageView * icon = [LCUIImageView viewWithImage:UIImage.IMAGE(@"LikeIcon.png")];
    icon.viewFrameX = self.view.viewMidWidth - icon.viewMidWidth;
    icon.viewFrameY = 60;
    self.view.ADD(icon);

    
    
    UIView * phoneBack = UIView.view.Y(icon.viewBottomY + 40).WIDTH(LC_DEVICE_WIDTH).HEIGHT(47).COLOR([[UIColor whiteColor] colorWithAlphaComponent:0.05]);
    self.view.ADD(phoneBack);
    
    
    UIImageView * phoneIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PhoneIcon.png" useCache:YES]];
    phoneIcon.viewFrameY = phoneBack.viewMidHeight - phoneIcon.viewMidHeight;
    phoneBack.ADD(phoneIcon);
    
    
    CGFloat allWidth = phoneIcon.viewFrameWidth + 270 / 3 + 24;
    CGFloat phoneX = LC_DEVICE_WIDTH / 2 - allWidth / 2;
    phoneIcon.viewFrameX = phoneX;
    

    self.phoneField = LCUITextField.view;
    self.phoneField.viewFrameY = 0;
    self.phoneField.viewFrameWidth = 270 / 3 + 50;
    self.phoneField.viewFrameHeight = 47;
    self.phoneField.viewFrameX = phoneIcon.viewRightX + 24;
    self.phoneField.font = LK_FONT(15);
    self.phoneField.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.phoneField.placeholder = LC_LO(@"输入手机号码");
    self.phoneField.placeholderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    self.phoneField.returnKeyType = UIReturnKeyNext;
    self.phoneField.keyboardType = UIKeyboardTypeNumberPad;
    phoneBack.ADD(self.phoneField);
    
    self.phoneField.shouldReturn = ^ BOOL (id value){
        
        @normally(self);
        
        [self.phoneField resignFirstResponder];
        return YES;
    };
    
    
    UIView * codeBack = UIView.view.Y(phoneBack.viewBottomY + 1).WIDTH(LC_DEVICE_WIDTH).HEIGHT(47).COLOR([[UIColor whiteColor] colorWithAlphaComponent:0.05]);
    self.view.ADD(codeBack);
    
    
    UIImageView * codeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CodeIcon.png" useCache:YES]];
    codeIcon.viewFrameY = codeBack.viewMidHeight - codeIcon.viewMidHeight;
    codeBack.ADD(codeIcon);
    
    
    CGFloat allWidth1 = codeIcon.viewFrameWidth + 270 / 3 + 24;
    CGFloat codeX = LC_DEVICE_WIDTH / 2 - allWidth1 / 2;
    codeIcon.viewFrameX = codeX;

    
    
    self.codeField = LCUITextField.view;
    self.codeField.viewFrameWidth = 270 / 3;
    self.codeField.viewFrameHeight = 47;
    self.codeField.viewFrameX = codeIcon.viewRightX + 24;
    self.codeField.font = LK_FONT(15);
    self.codeField.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.codeField.placeholder = LC_LO(@"输入验证码");
    self.codeField.placeholderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    self.codeField.returnKeyType = UIReturnKeyJoin;
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    codeBack.ADD(self.codeField);
    
    self.codeField.shouldReturn = ^ BOOL (id value){
        
        @normally(self);
        
        [self.codeField resignFirstResponder];
        [self getCode];
        return YES;
    };
    
    
    self.codeButton = LCUIButton.view;
    self.codeButton.viewFrameY = codeBack.viewBottomY + 25;
    self.codeButton.viewFrameWidth = 200;
    self.codeButton.viewFrameHeight = 25;
    self.codeButton.viewFrameX = LC_DEVICE_WIDTH / 2 - 100;
    self.codeButton.title = LC_LO(@"获取验证码");
    self.codeButton.titleColor = [UIColor whiteColor];
    self.codeButton.titleFont = LK_FONT(13);
    self.codeButton.showsTouchWhenHighlighted = YES;
    [self.codeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.codeButton);
    
    
    self.loginButton = LCUIButton.view;
    self.loginButton.viewFrameWidth = 132;
    self.loginButton.viewFrameHeight = 35;
    self.loginButton.viewFrameX = self.view.viewMidWidth - self.loginButton.viewMidWidth;
    self.loginButton.viewFrameY = self.codeButton.viewBottomY + 25;
    self.loginButton.cornerRadius = 35 / 2;
    self.loginButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    self.loginButton.title = LC_LO(@"进入like");
    self.loginButton.titleFont = LK_FONT(15);
    self.loginButton.titleColor = [UIColor whiteColor];
    self.loginButton.showsTouchWhenHighlighted = YES;
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    self.view.ADD(self.loginButton);
    
    
    LCUILabel * agreement = LCUILabel.view;
    agreement.viewFrameY = self.view.viewFrameHeight - 60;
    agreement.viewFrameWidth = self.view.viewFrameWidth;
    agreement.viewFrameHeight = 20;
    agreement.FIT();
    agreement.viewFrameX = LC_DEVICE_WIDTH / 2 - agreement.viewMidWidth;
    agreement.textAlignment = UITextAlignmentCenter;
    agreement.font = LK_FONT(10);
    agreement.text = LC_LO(@"用户使用协议");
    agreement.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [agreement addTapGestureRecognizer:self selector:@selector(agreement)];
    self.view.ADD(agreement);
    
    
    LCUIButton * visitor = LCUIButton.view;
    visitor.viewFrameWidth = 100;
    visitor.viewFrameX = self.view.viewFrameWidth - 5 - visitor.viewFrameWidth;
    visitor.viewFrameY = self.view.viewFrameHeight - 10 - 20;
    visitor.viewFrameHeight = 20;
    visitor.title = LC_LO(@"游客访问     ");
    visitor.titleFont = LK_FONT(10);
    visitor.titleColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [visitor addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    visitor.buttonImage = [[[UIImage imageNamed:@"VisitorIcon.png" useCache:YES] scaleToWidth:13] imageWithTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    visitor.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    self.view.ADD(visitor);
    
    
    self.maskView = LCUIButton.view;
    self.maskView.viewFrameWidth = LC_DEVICE_WIDTH;
    self.maskView.viewFrameHeight = LC_DEVICE_HEIGHT + 20;
    self.maskView.hidden = YES;
    self.view.ADD(self.maskView);
    
    
    
    for (UIView * view in self.view.subviews) {
        
        if (view != self.backgroundView) {
            
            view.alpha = 0;
        }
    }
    
    [self performSelector:@selector(beginAnimation) withObject:0 afterDelay:0.01];
}

-(void) dismissAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) agreement
{
    LCUIWebViewController * web = [[LCUIWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://terms.likeorz.com"]];
    [self presentViewController:LC_UINAVIGATION(web) animated:YES completion:nil];
    
    web.navigationController.navigationBar.barTintColor = LKColor.color;
}

-(void) getCode
{
    if (![self $check:YES]) {
        return;
    }

    [self cancelAllRequests];
    
    self.codeButton.userInteractionEnabled = NO;
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"user/sendcode"];
    [interface setMethodType:LKHttpRequestMethodTypePost];
    [interface addParameter:self.phoneField.text key:@"mobile"];
    
    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult * result) {
       
        @normally(self);

        if (result.state == LKHttpRequestStateFinished) {
            
            [self $beginTimer];
            
            self.codeButton.userInteractionEnabled = YES;
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            [self showTopMessageErrorHud:result.error];
            
            self.codeButton.userInteractionEnabled = YES;
        }
    }];
}

-(void) login
{
    if (![self $check:NO]) {
        return;
    }

    self.maskView.hidden = NO;
    self.loginButton.title = @"登录中...";
    self.loginButton.userInteractionEnabled = NO;
    
    LKHttpRequestInterface * interface = [LKHttpRequestInterface interfaceType:@"user"];
    [interface setMethodType:LKHttpRequestMethodTypePost];
    [interface addParameter:self.phoneField.text key:@"mobile"];
    [interface addParameter:self.codeField.text key:@"code"];

    @weakly(self);
    
    [self request:interface complete:^(LKHttpRequestResult * result) {
        
        @normally(self);
        
        if (result.state == LKHttpRequestStateFinished) {
            
            self.loginButton.userInteractionEnabled = YES;
            //self.loginButton.title = @"进入Like";

            self.sesstionToken = result.json[@"data"][@"session_token"];
            self.refreshToken = result.json[@"data"][@"refresh_token"];
            self.expiresIn = result.json[@"data"][@"expires_in"];
            
            [self.userInfoModel getUserInfo:result.json[@"data"][@"user_id"]];
        }
        else if (result.state == LKHttpRequestStateFailed){
            
            self.loginButton.userInteractionEnabled = YES;
            self.loginButton.title = @"进入like";

            self.maskView.hidden = YES;
            [self showTopMessageErrorHud:result.error];
        }
    }];
}

LC_HANDLE_TIMER(timer)
{
    if ([timer is:@"CodeTimer"]) {
        
        self.timeInterval -= 1;
        
        if (self.timeInterval <= 0) {
            
            [self $restoreTimer];
            return;
        }
        
        self.codeButton.title = LC_NSSTRING_FORMAT(@"%@秒后重新发送", @(self.timeInterval));
    }
}

-(void) $beginTimer
{
    self.timeInterval = 60;
    
    self.codeButton.userInteractionEnabled = NO;
    
    [self fireTimer:@"CodeTimer" timeInterval:1 repeat:YES];
}


-(void) $restoreTimer
{
    self.codeButton.userInteractionEnabled = YES;

    self.codeButton.title = LC_LO(@"获取验证码");
    [self cancelAllTimers];
}

-(BOOL) $check:(BOOL)codeOrLogin
{
    [self.phoneField resignFirstResponder];
    [self.codeField resignFirstResponder];
    
    if (self.phoneField.text.length == 0) {
        
        [self showTopMessageErrorHud:@"请输入手机号码"];
        return NO;
    }
    
    if (self.phoneField.text.length <= 5) {
        
        [self showTopMessageErrorHud:@"手机号码格式不正确"];
        return NO;
    }
    
    if (!codeOrLogin) {
        
        if (self.codeField.text.length <= 0) {
            
            [self showTopMessageErrorHud:@"请输入手机验证码"];
            return NO;
        }
    }
    
    return YES;
}

@end
